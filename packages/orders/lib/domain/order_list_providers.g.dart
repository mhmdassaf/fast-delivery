// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersFirestoreHash() => r'196a60cfc54dcc573e544be44c45a8b40585d1dc';

/// See also [ordersFirestore].
@ProviderFor(ordersFirestore)
final ordersFirestoreProvider = AutoDisposeProvider<FirebaseFirestore>.internal(
  ordersFirestore,
  name: r'ordersFirestoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersFirestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersFirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$ordersDataSourceHash() => r'1cef48a7ba9dbb54c4ebe490a83ffdb5b25439a4';

/// See also [ordersDataSource].
@ProviderFor(ordersDataSource)
final ordersDataSourceProvider =
    AutoDisposeProvider<OrderListDataSource>.internal(
  ordersDataSource,
  name: r'ordersDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersDataSourceRef = AutoDisposeProviderRef<OrderListDataSource>;
String _$ordersRepositoryHash() => r'b344239fe39fe0e9908aea43e8c6c52894d6b523';

/// See also [ordersRepository].
@ProviderFor(ordersRepository)
final ordersRepositoryProvider =
    AutoDisposeProvider<OrderListRepository>.internal(
  ordersRepository,
  name: r'ordersRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrdersRepositoryRef = AutoDisposeProviderRef<OrderListRepository>;
String _$orderStatusDescriptionOverridesHash() =>
    r'a1cb34d204d2ae5f21c39da8ce04bbe794ba0235';

/// Fetches dynamic status description overrides from Firestore config.
///
/// Reads `config/orderStatuses` document and returns a map of
/// enum name → description. Falls back to [OrderStatus.description] defaults
/// when this provider returns an empty map or is still loading.
///
/// Copied from [orderStatusDescriptionOverrides].
@ProviderFor(orderStatusDescriptionOverrides)
final orderStatusDescriptionOverridesProvider =
    AutoDisposeFutureProvider<Map<String, String>>.internal(
  orderStatusDescriptionOverrides,
  name: r'orderStatusDescriptionOverridesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderStatusDescriptionOverridesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OrderStatusDescriptionOverridesRef
    = AutoDisposeFutureProviderRef<Map<String, String>>;
String _$activeOrdersCountHash() => r'1a7994f9ec63c7b6772c2fded51109c6daa2de0c';

/// Returns the number of active orders for the currently logged-in user/role.
///
/// Uses Firestore's `count()` aggregation — no documents are fetched.
/// Returns `0` when the user is unauthenticated or when the query fails silently.
/// Invalidate this provider (e.g. when switching to the Home tab) to refresh.
///
/// Copied from [activeOrdersCount].
@ProviderFor(activeOrdersCount)
final activeOrdersCountProvider = AutoDisposeFutureProvider<int>.internal(
  activeOrdersCount,
  name: r'activeOrdersCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeOrdersCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveOrdersCountRef = AutoDisposeFutureProviderRef<int>;
String _$orderListNotifierHash() => r'dff780c7108526114007f635e1780a02c67b9c9c';

/// Notifier managing the orders list state.
///
/// Copied from [OrderListNotifier].
@ProviderFor(OrderListNotifier)
final orderListNotifierProvider =
    AutoDisposeNotifierProvider<OrderListNotifier, OrderListState>.internal(
  OrderListNotifier.new,
  name: r'orderListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$orderListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrderListNotifier = AutoDisposeNotifier<OrderListState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
