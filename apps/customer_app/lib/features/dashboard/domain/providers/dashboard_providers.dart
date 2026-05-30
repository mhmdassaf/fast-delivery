import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fast_delivery_core/errors/result.dart';

import '../../data/datasources/dashboard_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/models/shop_filter_model.dart';
import '../../data/models/shop_model.dart';
import '../../data/repositories/dashboard_repository.dart';

part 'dashboard_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

/// Firebase Firestore instance provider
@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

/// Dashboard data source provider
@riverpod
DashboardDataSource dashboardDataSource(Ref ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return DashboardDataSourceImpl(firestore: firestore);
}

// ============================================================================
// Repositories
// ============================================================================

/// Dashboard repository provider
@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  final dataSource = ref.watch(dashboardDataSourceProvider);
  return DashboardRepositoryImpl(dataSource: dataSource);
}

// ============================================================================
// Dashboard State
// ============================================================================

/// Sentinel for distinguishing "not provided" from "explicitly set to null"
// in copyWith methods for nullable fields.
const _Unset = Object();

/// State class for the dashboard
class DashboardState {
  /// List of loaded shops
  final List<ShopModel> shops;

  /// List of available categories
  final List<CategoryModel> categories;

  /// Currently selected category ID (null means "All")
  final String? selectedCategoryId;

  /// Current search query
  final String searchQuery;

  /// Whether the initial data is loading
  final bool isLoading;

  /// Whether more shops are being loaded (pagination)
  final bool isLoadingMore;

  /// Whether a refresh is in progress
  final bool isRefreshing;

  /// Error message (null when no error)
  final String? errorMessage;

  /// Cursor for pagination
  final DocumentSnapshot<Object?>? lastDocument;

  /// Whether there are more shops to load
  final bool hasMoreData;

  /// Current filter settings
  final ShopFilterModel filter;

  const DashboardState({
    this.shops = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastDocument,
    this.hasMoreData = true,
    this.filter = const ShopFilterModel(),
  });

  /// The selected category model (null if "All" is selected)
  CategoryModel? get selectedCategory =>
      categories.where((c) => c.id == selectedCategoryId).firstOrNull;

  /// Whether there are any shops to display
  bool get hasShops => shops.isNotEmpty;

  /// Whether there are any errors
  bool get hasError => errorMessage != null;

  /// Whether there is any active filter (beyond category selection)
  bool get hasActiveFilters => filter.hasActiveFilters;

  DashboardState copyWith({
    List<ShopModel>? shops,
    List<CategoryModel>? categories,
    Object? selectedCategoryId = _Unset,
    String? searchQuery,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    Object? lastDocument = _Unset,
    bool? hasMoreData,
    ShopFilterModel? filter,
  }) {
    return DashboardState(
      shops: shops ?? this.shops,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId == _Unset
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastDocument: lastDocument == _Unset
          ? this.lastDocument
          : lastDocument as DocumentSnapshot<Object?>?,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      filter: filter ?? this.filter,
    );
  }
}

// ============================================================================
// Dashboard Notifier (State Management)
// ============================================================================

/// Debouncer utility for search input
class _Debouncer {
  static const Duration _kDelay = Duration(milliseconds: 300);
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(_kDelay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Dashboard notifier for managing dashboard state
@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  _Debouncer? _searchDebouncer;

  @override
  DashboardState build() {
    _searchDebouncer = _Debouncer();
    ref.onDispose(() => _searchDebouncer?.dispose());
    return const DashboardState();
  }

  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  // ==========================================================================
  // Shared Helpers (reduce duplication)
  // ==========================================================================

  /// Handle a categories [Result] — update state with categories or error.
  void _handleCategoriesResult(Result<List<CategoryModel>> result) {
    result.fold(
      onSuccess: (categories) => state = state.copyWith(categories: categories),
      onFailure: (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
    );
  }

  /// Handle a shops [Result] — update state with shops, cursor, and hasMore.
  void _handleShopsResult(Result<ShopsResult> result, {bool append = false}) {
    result.fold(
      onSuccess: (result) {
        state = state.copyWith(
          shops: append ? [...state.shops, ...result.shops] : result.shops,
          lastDocument: result.lastDocument,
          hasMoreData: result.hasMore,
        );
      },
      onFailure: (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
    );
  }

  /// Fetch both categories and shops in parallel, then handle both results.
  Future<void> _fetchCategoriesAndShops() async {
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getShops(
        categoryId: state.selectedCategoryId,
        filter: state.filter,
        searchQuery: state.searchQuery,
        lastDocument: null,
      ),
    ]);
    _handleCategoriesResult(results[0] as Result<List<CategoryModel>>);
    _handleShopsResult(results[1] as Result<ShopsResult>);
  }

  // ==========================================================================
  // Initial Data Loading
  // ==========================================================================

  /// Load initial data: categories + first page of shops
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetchCategoriesAndShops();
    state = state.copyWith(isLoading: false);
  }

  // ==========================================================================
  // Pagination
  // ==========================================================================

  /// Load more shops (pagination)
  Future<void> loadMoreShops() async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    state = state.copyWith(isLoadingMore: true);

    final result = await _repository.getShops(
      categoryId: state.selectedCategoryId,
      filter: state.filter,
      searchQuery: state.searchQuery,
      lastDocument: state.lastDocument,
    );

    _handleShopsResult(result, append: true);
    state = state.copyWith(isLoadingMore: false);
  }

  // ==========================================================================
  // Pull to Refresh
  // ==========================================================================

  /// Refresh all data
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    await _fetchCategoriesAndShops();
    state = state.copyWith(isRefreshing: false);
  }

  // ==========================================================================
  // Category Selection
  // ==========================================================================

  /// Select a category by ID. Pass null to select "All".
  Future<void> selectCategory(String? categoryId) async {
    if (state.selectedCategoryId == categoryId) return;

    state = state.copyWith(
      selectedCategoryId: categoryId,
      shops: [],
      lastDocument: null,
      hasMoreData: true,
      isLoading: true,
      clearError: true,
    );

    final result = await _repository.getShops(
      categoryId: categoryId,
      filter: state.filter,
      searchQuery: state.searchQuery,
      lastDocument: null,
    );

    _handleShopsResult(result);
    state = state.copyWith(isLoading: false);
  }

  // ==========================================================================
  // Search
  // ==========================================================================

  /// Update search query with debounce
  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _searchDebouncer?.call(() => _executeSearch(query));
  }

  /// Clear search and reload
  Future<void> clearSearch() async {
    state = state.copyWith(searchQuery: '', shops: [], lastDocument: null, hasMoreData: true, isLoading: true);
    await _reloadShops();
  }

  /// Execute the actual search after debounce
  Future<void> _executeSearch(String query) async {
    state = state.copyWith(shops: [], lastDocument: null, hasMoreData: true, isLoading: true);

    final result = await _repository.getShops(
      categoryId: state.selectedCategoryId,
      filter: state.filter,
      searchQuery: query,
      lastDocument: null,
    );

    _handleShopsResult(result);
    state = state.copyWith(isLoading: false);
  }

  // ==========================================================================
  // Filtering
  // ==========================================================================

  /// Update the current filter and reload shops
  Future<void> updateFilter(ShopFilterModel newFilter) async {
    state = state.copyWith(
      filter: newFilter,
      shops: [],
      lastDocument: null,
      hasMoreData: true,
      isLoading: true,
      clearError: true,
    );

    final result = await _repository.getShops(
      categoryId: state.selectedCategoryId,
      filter: newFilter,
      searchQuery: state.searchQuery,
      lastDocument: null,
    );

    _handleShopsResult(result);
    state = state.copyWith(isLoading: false);
  }

  /// Clear all filters (keep category selection) and reload
  Future<void> clearFilters() async {
    final defaultFilter = const ShopFilterModel();
    await updateFilter(defaultFilter);
  }

  /// Toggle open now filter
  Future<void> toggleOpenNow() async {
    final newFilter = state.filter.toggleOpenNow();
    await updateFilter(newFilter);
  }

  /// Remove the min rating filter and reload
  Future<void> removeRatingFilter() async {
    final newFilter = state.filter.copyWith(minRating: null);
    await updateFilter(newFilter);
  }

  /// Remove the max delivery fee filter and reload
  Future<void> removeDeliveryFeeFilter() async {
    final newFilter = state.filter.copyWith(maxDeliveryFee: null);
    await updateFilter(newFilter);
  }

  // ==========================================================================
  // Utilities
  // ==========================================================================

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reload shops with current state (used internally)
  Future<void> _reloadShops() async {
    final result = await _repository.getShops(
      categoryId: state.selectedCategoryId,
      filter: state.filter,
      searchQuery: state.searchQuery,
      lastDocument: null,
    );

    _handleShopsResult(result);
    state = state.copyWith(isLoading: false);
  }
}
