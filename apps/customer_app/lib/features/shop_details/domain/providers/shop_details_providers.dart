import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fast_delivery_core/errors/result.dart';

import '../../data/datasources/shop_details_datasource.dart';
import '../../data/models/menu_item_group.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/repositories/shop_details_repository.dart';
import '../../../dashboard/data/models/shop_model.dart';

part 'shop_details_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

/// Firebase Firestore instance provider (shared with dashboard).
@riverpod
FirebaseFirestore shopDetailsFirebaseFirestore(Ref ref) =>
    FirebaseFirestore.instance;

/// Shop details data source provider.
@riverpod
ShopDetailsDataSource shopDetailsDataSource(Ref ref) {
  final firestore = ref.watch(shopDetailsFirebaseFirestoreProvider);
  return ShopDetailsDataSourceImpl(firestore: firestore);
}

// ============================================================================
// Repositories
// ============================================================================

/// Shop details repository provider.
@riverpod
ShopDetailsRepository shopDetailsRepository(Ref ref) {
  final dataSource = ref.watch(shopDetailsDataSourceProvider);
  return ShopDetailsRepositoryImpl(dataSource: dataSource);
}

// ============================================================================
// Shop Details State
// ============================================================================

/// State class for shop details and menu.
class ShopDetailsState {
  /// The shop model (null while loading or on error).
  final ShopModel? shop;

  /// All menu items fetched for this shop.
  final List<MenuItemModel> menuItems;

  /// Menu items grouped by [MenuItemModel.category].
  ///
  /// Derived from [menuItems] — each group has a unique category name
  /// and its items sorted by [MenuItemModel.order].
  final List<MenuItemGroup> groupedMenuItems;

  /// Whether the initial data is loading.
  final bool isLoading;

  /// Error message (null when no error).
  final String? errorMessage;

  const ShopDetailsState({
    this.shop,
    this.menuItems = const [],
    this.groupedMenuItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Whether there are any menu items to display.
  bool get hasMenuItems => menuItems.isNotEmpty;

  /// Whether there is an error.
  bool get hasError => errorMessage != null;

  ShopDetailsState copyWith({
    ShopModel? shop,
    List<MenuItemModel>? menuItems,
    List<MenuItemGroup>? groupedMenuItems,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShopDetailsState(
      shop: shop ?? this.shop,
      menuItems: menuItems ?? this.menuItems,
      groupedMenuItems: groupedMenuItems ?? this.groupedMenuItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Build [groupedMenuItems] from a flat [menuItems] list.
  ///
  /// Items are grouped by their [MenuItemModel.category] field.
  /// Within each group, items retain their original order (already sorted
  /// by [MenuItemModel.order] from the query).
  static List<MenuItemGroup> groupItems(List<MenuItemModel> items) {
    if (items.isEmpty) return [];

    final Map<String, List<MenuItemModel>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []);
      grouped[item.category]!.add(item);
    }

    return grouped.entries
        .map((entry) => MenuItemGroup(
              category: entry.key,
              items: entry.value,
            ))
        .toList();
  }
}

// ============================================================================
// Shop Details Notifier (State Management)
// ============================================================================

/// Notifier for managing shop details and menu state.
///
/// Uses the [shopId] passed at creation time to fetch the relevant
/// shop document and its menu items subcollection.
@riverpod
class ShopDetailsNotifier extends _$ShopDetailsNotifier {
  @override
  ShopDetailsState build(String shopId) {
    // Automatically load data when the notifier is first created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadShopDetails();
    });
    // Start with isLoading=true so the skeleton shows while Firestore loads.
    return const ShopDetailsState(isLoading: true);
  }

  ShopDetailsRepository get _repository =>
      ref.read(shopDetailsRepositoryProvider);

  // ==========================================================================
  // Data Loading
  // ==========================================================================

  /// Fetch the shop document and its menu items in parallel.
  Future<void> loadShopDetails() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final results = await Future.wait([
      _repository.getShopById(shopId),
      _repository.getMenuItems(shopId),
    ]);

    final shopResult = results[0] as Result<ShopModel>;
    final menuResult = results[1] as Result<List<MenuItemModel>>;

    shopResult.fold(
      onSuccess: (shop) {
        state = state.copyWith(shop: shop);
      },
      onFailure: (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );

    menuResult.fold(
      onSuccess: (items) {
        final grouped = ShopDetailsState.groupItems(items);
        state = state.copyWith(
          menuItems: items,
          groupedMenuItems: grouped,
        );
      },
      onFailure: (failure) {
        // Only set error if shop also failed, otherwise just menu fails silently.
        if (state.shop == null) {
          state = state.copyWith(errorMessage: failure.message);
        }
      },
    );

    state = state.copyWith(isLoading: false);
  }

  // ==========================================================================
  // Utilities
  // ==========================================================================

  /// Clear the error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
