// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_details_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shopDetailsFirebaseFirestoreHash() =>
    r'9c88ac8c1cb9a0dd3707f779f9871192ee991d52';

/// Firebase Firestore instance provider (shared with dashboard).
///
/// Copied from [shopDetailsFirebaseFirestore].
@ProviderFor(shopDetailsFirebaseFirestore)
final shopDetailsFirebaseFirestoreProvider =
    AutoDisposeProvider<FirebaseFirestore>.internal(
      shopDetailsFirebaseFirestore,
      name: r'shopDetailsFirebaseFirestoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shopDetailsFirebaseFirestoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopDetailsFirebaseFirestoreRef =
    AutoDisposeProviderRef<FirebaseFirestore>;
String _$shopDetailsDataSourceHash() =>
    r'158efad4ce03975e5e710ebf1a7e8b5f39e60577';

/// Shop details data source provider.
///
/// Copied from [shopDetailsDataSource].
@ProviderFor(shopDetailsDataSource)
final shopDetailsDataSourceProvider =
    AutoDisposeProvider<ShopDetailsDataSource>.internal(
      shopDetailsDataSource,
      name: r'shopDetailsDataSourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shopDetailsDataSourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopDetailsDataSourceRef =
    AutoDisposeProviderRef<ShopDetailsDataSource>;
String _$shopDetailsRepositoryHash() =>
    r'f001f065b77491775dc34598c2a52bb409359948';

/// Shop details repository provider.
///
/// Copied from [shopDetailsRepository].
@ProviderFor(shopDetailsRepository)
final shopDetailsRepositoryProvider =
    AutoDisposeProvider<ShopDetailsRepository>.internal(
      shopDetailsRepository,
      name: r'shopDetailsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$shopDetailsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShopDetailsRepositoryRef =
    AutoDisposeProviderRef<ShopDetailsRepository>;
String _$shopDetailsNotifierHash() =>
    r'4456037bc3e94c3b97979101de32ab3df1934935';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ShopDetailsNotifier
    extends BuildlessAutoDisposeNotifier<ShopDetailsState> {
  late final String shopId;

  ShopDetailsState build(String shopId);
}

/// Notifier for managing shop details and menu state.
///
/// Uses the [shopId] passed at creation time to fetch the relevant
/// shop document and its menu items subcollection.
///
/// Copied from [ShopDetailsNotifier].
@ProviderFor(ShopDetailsNotifier)
const shopDetailsNotifierProvider = ShopDetailsNotifierFamily();

/// Notifier for managing shop details and menu state.
///
/// Uses the [shopId] passed at creation time to fetch the relevant
/// shop document and its menu items subcollection.
///
/// Copied from [ShopDetailsNotifier].
class ShopDetailsNotifierFamily extends Family<ShopDetailsState> {
  /// Notifier for managing shop details and menu state.
  ///
  /// Uses the [shopId] passed at creation time to fetch the relevant
  /// shop document and its menu items subcollection.
  ///
  /// Copied from [ShopDetailsNotifier].
  const ShopDetailsNotifierFamily();

  /// Notifier for managing shop details and menu state.
  ///
  /// Uses the [shopId] passed at creation time to fetch the relevant
  /// shop document and its menu items subcollection.
  ///
  /// Copied from [ShopDetailsNotifier].
  ShopDetailsNotifierProvider call(String shopId) {
    return ShopDetailsNotifierProvider(shopId);
  }

  @override
  ShopDetailsNotifierProvider getProviderOverride(
    covariant ShopDetailsNotifierProvider provider,
  ) {
    return call(provider.shopId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shopDetailsNotifierProvider';
}

/// Notifier for managing shop details and menu state.
///
/// Uses the [shopId] passed at creation time to fetch the relevant
/// shop document and its menu items subcollection.
///
/// Copied from [ShopDetailsNotifier].
class ShopDetailsNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<ShopDetailsNotifier, ShopDetailsState> {
  /// Notifier for managing shop details and menu state.
  ///
  /// Uses the [shopId] passed at creation time to fetch the relevant
  /// shop document and its menu items subcollection.
  ///
  /// Copied from [ShopDetailsNotifier].
  ShopDetailsNotifierProvider(String shopId)
    : this._internal(
        () => ShopDetailsNotifier()..shopId = shopId,
        from: shopDetailsNotifierProvider,
        name: r'shopDetailsNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$shopDetailsNotifierHash,
        dependencies: ShopDetailsNotifierFamily._dependencies,
        allTransitiveDependencies:
            ShopDetailsNotifierFamily._allTransitiveDependencies,
        shopId: shopId,
      );

  ShopDetailsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.shopId,
  }) : super.internal();

  final String shopId;

  @override
  ShopDetailsState runNotifierBuild(covariant ShopDetailsNotifier notifier) {
    return notifier.build(shopId);
  }

  @override
  Override overrideWith(ShopDetailsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ShopDetailsNotifierProvider._internal(
        () => create()..shopId = shopId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        shopId: shopId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ShopDetailsNotifier, ShopDetailsState>
  createElement() {
    return _ShopDetailsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopDetailsNotifierProvider && other.shopId == shopId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, shopId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShopDetailsNotifierRef
    on AutoDisposeNotifierProviderRef<ShopDetailsState> {
  /// The parameter `shopId` of this provider.
  String get shopId;
}

class _ShopDetailsNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ShopDetailsNotifier,
          ShopDetailsState
        >
    with ShopDetailsNotifierRef {
  _ShopDetailsNotifierProviderElement(super.provider);

  @override
  String get shopId => (origin as ShopDetailsNotifierProvider).shopId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
