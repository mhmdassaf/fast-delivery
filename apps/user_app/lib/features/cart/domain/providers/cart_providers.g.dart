// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartItemCountHash() => r'e6b825429c3ed1cbd82583f0522c49b75cbe972e';

/// Total number of items across all cart entries (sum of quantities).
///
/// Copied from [cartItemCount].
@ProviderFor(cartItemCount)
final cartItemCountProvider = AutoDisposeProvider<int>.internal(
  cartItemCount,
  name: r'cartItemCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartItemCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartItemCountRef = AutoDisposeProviderRef<int>;
String _$cartTotalHash() => r'cdf53ca430a2d118845bcd7bd12eb4ede6bbb4d4';

/// Total price of all items in the cart.
///
/// Copied from [cartTotal].
@ProviderFor(cartTotal)
final cartTotalProvider = AutoDisposeProvider<double>.internal(
  cartTotal,
  name: r'cartTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartTotalRef = AutoDisposeProviderRef<double>;
String _$cartShopIdHash() => r'582a2ad8641a1a327026d8cb686b97c1f2c9d030';

/// The [shopId] of items currently in the cart.
///
/// Returns `null` when the cart is empty. If items from multiple shops end up
/// in the cart (edge case), returns the first shop's ID.
///
/// Copied from [cartShopId].
@ProviderFor(cartShopId)
final cartShopIdProvider = AutoDisposeProvider<String?>.internal(
  cartShopId,
  name: r'cartShopIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartShopIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartShopIdRef = AutoDisposeProviderRef<String?>;
String _$cartShopNameHash() => r'4f9b900504a177c7d766f2d5bf267bd3544903df';

/// The [shopName] of items currently in the cart.
///
/// Copied from [cartShopName].
@ProviderFor(cartShopName)
final cartShopNameProvider = AutoDisposeProvider<String?>.internal(
  cartShopName,
  name: r'cartShopNameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartShopNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CartShopNameRef = AutoDisposeProviderRef<String?>;
String _$hasCartItemsHash() => r'0f821df7a7928150693deb738d481738e67682c8';

/// Whether any cart items exist.
///
/// Copied from [hasCartItems].
@ProviderFor(hasCartItems)
final hasCartItemsProvider = AutoDisposeProvider<bool>.internal(
  hasCartItems,
  name: r'hasCartItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasCartItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasCartItemsRef = AutoDisposeProviderRef<bool>;
String _$cartNotifierHash() => r'd2cafdfa1b2ee721b1b87d4eb877062759267ac9';

/// Notifier for the user's shopping cart.
///
/// State is persisted to local storage via shared_preferences so it survives
/// app restarts. The initial state is an empty list while prefs load asynchronously.
///
/// Copied from [CartNotifier].
@ProviderFor(CartNotifier)
final cartNotifierProvider =
    AutoDisposeNotifierProvider<CartNotifier, List<CartItemModel>>.internal(
      CartNotifier.new,
      name: r'cartNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cartNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CartNotifier = AutoDisposeNotifier<List<CartItemModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
