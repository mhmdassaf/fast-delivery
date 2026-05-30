import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fast_delivery_auth/domain/providers/auth_providers.dart';

import '../data/datasources/order_list_datasource.dart';
import '../data/models/order_list_item_model.dart';
import '../data/repositories/order_list_repository.dart';
import 'order_status.dart';

part 'order_list_providers.g.dart';

// ============================================================================
// Infrastructure providers
// ============================================================================

@riverpod
FirebaseFirestore ordersFirestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
OrderListDataSource ordersDataSource(Ref ref) {
  final firestore = ref.watch(ordersFirestoreProvider);
  return OrderListDataSourceImpl(firestore: firestore);
}

@riverpod
OrderListRepository ordersRepository(Ref ref) {
  final dataSource = ref.watch(ordersDataSourceProvider);
  return OrderListRepositoryImpl(dataSource: dataSource);
}

/// Fetches dynamic status description overrides from Firestore config.
///
/// Reads `config/orderStatuses` document and returns a map of
/// enum name → description. Falls back to [OrderStatus.description] defaults
/// when this provider returns an empty map or is still loading.
@riverpod
Future<Map<String, String>> orderStatusDescriptionOverrides(Ref ref) async {
  try {
    final firestore = ref.watch(ordersFirestoreProvider);
    final doc = await firestore.collection('config').doc('orderStatuses').get();
    final data = doc.data();
    if (data != null && data['descriptions'] is Map) {
      return Map<String, String>.from(data['descriptions'] as Map);
    }
  } catch (_) {}
  return {};
}

/// Returns the number of active orders for the currently logged-in user/role.
///
/// Uses Firestore's `count()` aggregation — no documents are fetched.
/// Returns `0` when the user is unauthenticated or when the query fails silently.
/// Invalidate this provider (e.g. when switching to the Home tab) to refresh.
@riverpod
Future<int> activeOrdersCount(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final repo = ref.watch(ordersRepositoryProvider);
  final result = await repo.getActiveOrderCount(
    role: user.role.name,
    uid: user.uid,
    statuses: StatusFilterOption.active.statuses!,
  );

  return result.fold(
    onSuccess: (count) => count,
    onFailure: (_) => 0,
  );
}

// ============================================================================
// OrderListState
// ============================================================================

/// State for the orders list screen.
class OrderListState {
  /// The list of loaded orders.
  final List<OrderListItemModel> orders;

  /// Currently selected status filter (null = "All").
  final String? selectedStatusFilter;

  /// Whether initial data is loading.
  final bool isLoading;

  /// Whether more orders are being loaded (pagination).
  final bool isLoadingMore;

  /// Whether a pull-to-refresh is in progress.
  final bool isRefreshing;

  /// Error message (null when no error).
  final String? errorMessage;

  /// Cursor for pagination.
  final DocumentSnapshot<Object?>? lastDocument;

  /// Whether there are more orders to load.
  final bool hasMoreData;

  const OrderListState({
    this.orders = const [],
    this.selectedStatusFilter,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastDocument,
    this.hasMoreData = true,
  });

  /// Whether there are any orders to display.
  bool get hasOrders => orders.isNotEmpty;

  /// Whether there is an error to display.
  bool get hasError => errorMessage != null;

  OrderListState copyWith({
    List<OrderListItemModel>? orders,
    Object? selectedStatusFilter = _Unset,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    Object? lastDocument = _Unset,
    bool? hasMoreData,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      selectedStatusFilter: selectedStatusFilter == _Unset
          ? this.selectedStatusFilter
          : selectedStatusFilter as String?,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastDocument: lastDocument == _Unset
          ? this.lastDocument
          : lastDocument as DocumentSnapshot<Object?>?,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

/// Sentinel for distinguishing "not provided" from "explicitly set to null"
const _Unset = Object();

// ============================================================================
// OrderListNotifier
// ============================================================================

/// Available status filter options.
enum StatusFilterOption {
  all('All', Icons.all_inclusive_rounded, null),
  active('Active', Icons.bolt_rounded, [
    OrderStatus.waitingRiderConfirmation,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.outForDelivery,
  ]),
  completed('Completed', Icons.check_circle_rounded, [OrderStatus.delivered]),
  cancelled('Cancelled', Icons.cancel_rounded, [OrderStatus.cancelled]);

  final String label;
  final IconData icon;
  final List<OrderStatus>? statuses;

  const StatusFilterOption(this.label, this.icon, this.statuses);

  /// The Firestore status group key (null for "All").
  String? get filterValue =>
      this == StatusFilterOption.all ? null : label;

  /// Resolves a [StatusFilterOption] from its [filterValue].
  ///
  /// Returns [StatusFilterOption.all] when the value is `null` or unknown.
  static StatusFilterOption fromFilterValue(String? filterValue) {
    return StatusFilterOption.values.firstWhere(
      (option) => option.filterValue == filterValue,
      orElse: () => StatusFilterOption.all,
    );
  }
}

/// Notifier managing the orders list state.
@riverpod
class OrderListNotifier extends _$OrderListNotifier {
  @override
  OrderListState build() {
    // Load orders after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders(reset: true);
    });
    return const OrderListState(isLoading: true);
  }

  OrderListRepository get _repository => ref.read(ordersRepositoryProvider);

  /// Load orders — either initial or paginated.
  Future<void> _loadOrders({bool reset = false}) async {
    final user = ref.read(currentUserProvider);
    final uid = user?.uid ?? '';
    if (uid.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: 'User not authenticated',
      );
      return;
    }

    final cursor = reset ? null : state.lastDocument;
    final statuses = StatusFilterOption.fromFilterValue(
      state.selectedStatusFilter,
    ).statuses;

    final result = await _repository.getOrders(
      role: user?.role.name ?? 'customer',
      uid: uid,
      statuses: statuses,
      cursor: cursor,
    );

    result.fold(
      onSuccess: (result) {
        state = state.copyWith(
          orders: reset ? result.orders : [...state.orders, ...result.orders],
          lastDocument: result.lastDocument,
          hasMoreData: result.hasMore,
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          clearError: true,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  // ==========================================================================
  // Public methods
  // ==========================================================================

  /// Load initial data (called automatically on build).
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _loadOrders(reset: true);
  }

  /// Load the next page of orders (pagination).
  Future<void> loadMoreOrders() async {
    if (state.isLoadingMore || !state.hasMoreData) return;
    state = state.copyWith(isLoadingMore: true);
    await _loadOrders(reset: false);
  }

  /// Pull-to-refresh — reload all orders.
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    await _loadOrders(reset: true);
  }

  /// Change the status filter and reload.
  Future<void> setStatusFilter(String? filterValue) async {
    if (state.selectedStatusFilter == filterValue) return;
    state = state.copyWith(
      selectedStatusFilter: filterValue,
      orders: [],
      lastDocument: null,
      hasMoreData: true,
      isLoading: true,
      clearError: true,
    );
    await _loadOrders(reset: true);
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
