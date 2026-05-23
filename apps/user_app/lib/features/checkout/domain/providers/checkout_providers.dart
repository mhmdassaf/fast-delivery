import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';
import 'package:fast_delivery_auth/domain/providers/auth_providers.dart';

import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/domain/providers/cart_providers.dart';
import '../../data/datasources/checkout_datasource.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/models/delivery_address_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_user_info.dart';
import '../../data/repositories/checkout_repository.dart';
import '../../data/repositories/location_repository.dart';

part 'checkout_providers.g.dart';

/// Lebanon country code used across checkout flow.
/// Defined once here — import this constant to avoid duplication.
const kLebanonCountryCode = '+961';

// ============================================================================
// Infrastructure providers
// ============================================================================

@riverpod
FirebaseFirestore checkoutFirestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
CheckoutDataSource checkoutDataSource(Ref ref) {
  final firestore = ref.watch(checkoutFirestoreProvider);
  return CheckoutDataSourceImpl(firestore: firestore);
}

@riverpod
CheckoutRepository checkoutRepository(Ref ref) {
  final dataSource = ref.watch(checkoutDataSourceProvider);
  return CheckoutRepositoryImpl(dataSource: dataSource);
}

@riverpod
LocationDataSource locationDataSource(Ref ref) => LocationDataSourceImpl();

@riverpod
LocationRepository locationRepository(Ref ref) {
  final dataSource = ref.watch(locationDataSourceProvider);
  return LocationRepositoryImpl(dataSource: dataSource);
}

// ============================================================================
// CheckoutState
// ============================================================================

/// Holds the full UI state for the checkout screen.
class CheckoutState {
  /// The delivery address selected by the user.
  final DeliveryAddressModel? deliveryAddress;

  /// Delivery time label fetched from the shop document (e.g. "30-45 min").
  final String deliveryTimeLabel;

  /// Delivery fee fetched from the shop document.
  final double deliveryFee;

  /// Whether shop delivery info is still loading.
  final bool isLoadingShopInfo;

  /// Whether the order is currently being placed.
  final bool isPlacingOrder;

  /// Error message to display (null if no error).
  final String? errorMessage;

  /// The ID of the created order (set after successful placement).
  final String? createdOrderId;

  /// The customer's phone number (mandatory — rider contact).
  final String phoneNumber;

  const CheckoutState({
    this.deliveryAddress,
    this.deliveryTimeLabel = '',
    this.deliveryFee = 0.0,
    this.isLoadingShopInfo = false,
    this.isPlacingOrder = false,
    this.errorMessage,
    this.createdOrderId,
    this.phoneNumber = '',
  });

  CheckoutState copyWith({
    DeliveryAddressModel? Function()? deliveryAddress,
    String? deliveryTimeLabel,
    double? deliveryFee,
    bool? isLoadingShopInfo,
    bool? isPlacingOrder,
    String? errorMessage,
    String? createdOrderId,
    String? phoneNumber,
  }) {
    return CheckoutState(
      deliveryAddress:
          deliveryAddress != null ? deliveryAddress() : this.deliveryAddress,
      deliveryTimeLabel: deliveryTimeLabel ?? this.deliveryTimeLabel,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isLoadingShopInfo: isLoadingShopInfo ?? this.isLoadingShopInfo,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      errorMessage: errorMessage ?? this.errorMessage,
      createdOrderId: createdOrderId ?? this.createdOrderId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

}

// ============================================================================
// CheckoutNotifier
// ============================================================================

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() {
    _loadShopInfo();
    _loadInitialAddress();
    _loadInitialPhone();
    return const CheckoutState(isLoadingShopInfo: true);
  }

  CheckoutRepository get _checkoutRepo =>
      ref.read(checkoutRepositoryProvider);
  LocationRepository get _locationRepo =>
      ref.read(locationRepositoryProvider);
  List<CartItemModel> get _cartItems =>
      ref.read(cartNotifierProvider);
  double get _subtotal =>
      ref.read(cartTotalProvider);
  String? get _shopId =>
      ref.read(cartShopIdProvider);
  String? get _shopName =>
      ref.read(cartShopNameProvider);

  /// Fetches the shop's deliveryTime and deliveryFee from Firestore.
  Future<void> _loadShopInfo() async {
    final shopId = _shopId;
    if (shopId == null) return;

    final result = await _checkoutRepo.getShopDeliveryInfo(shopId);
    result.fold(
      onSuccess: (info) {
        state = state.copyWith(
          deliveryTimeLabel: info['deliveryTime'] as String? ?? '',
          deliveryFee: (info['deliveryFee'] as num?)?.toDouble() ?? 0.0,
          isLoadingShopInfo: false,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoadingShopInfo: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Attempts to load the device's current location as the default address.
  Future<void> _loadInitialAddress() async {
    final result = await _locationRepo.getCurrentAddress();
    result.fold(
      onSuccess: (address) {
        state = state.copyWith(deliveryAddress: () => address);
      },
      onFailure: (_) {
        // Silently fail — user can manually set address later
      },
    );
  }

  /// Loads the user's phone number from their Firebase user model first, then
  /// falls back to the Firestore user document.
  ///
  /// If a phone number exists, it strips the leading '+' and country code so
  /// the [PhoneNumberSection] can display just the local number.
  Future<void> _loadInitialPhone() async {
    final authUser = ref.read(currentUserProvider);
    final userId = authUser?.uid;
    if (userId == null || userId.isEmpty) return;

    // 1. Try phone from the current user model (Firebase Auth or Firestore)
    if (authUser!.phoneNumber != null && authUser.phoneNumber!.isNotEmpty) {
      final localNumber = _stripCountryCode(authUser.phoneNumber!);
      if (localNumber.isNotEmpty) {
        state = state.copyWith(phoneNumber: localNumber);
        return;
      }
    }

    // 2. Fallback: fetch phone from Firestore users document
    final result = await _checkoutRepo.getUserPhone(userId);
    result.fold(
      onSuccess: (phone) {
        if (phone != null && phone.isNotEmpty) {
          final localNumber = _stripCountryCode(phone);
          if (localNumber.isNotEmpty) {
            state = state.copyWith(phoneNumber: localNumber);
          }
        }
      },
      onFailure: (_) {
        // Silently fail — user can enter phone manually
      },
    );
  }

  /// Strips the leading '+' and country code (1-3 digits after '+')
  /// from a full phone number (e.g. "+96170123456" → "70123456").
  ///
  /// If the number has no leading '+' it is returned unchanged.
  String _stripCountryCode(String phone) {
    return phone.replaceFirst(RegExp(r'^\+\d{1,3}'), '');
  }

  /// Sets the delivery address manually.
  void setAddress(DeliveryAddressModel address) {
    state = state.copyWith(
      deliveryAddress: () => address,
      errorMessage: null,
    );
  }

  /// Sets the customer's phone number.
  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      errorMessage: null,
    );
  }

  /// Fetches the device's current location and updates the delivery address.
  Future<void> useDeviceLocation() async {
    final result = await _locationRepo.getCurrentAddress();
    result.fold(
      onSuccess: (address) {
        state = state.copyWith(
          deliveryAddress: () => address,
          errorMessage: null,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );
  }

  /// Places the order by creating a Firestore document.
  ///
  /// Returns a [Result] so the screen can react appropriately.
  Future<Result<String>> placeOrder() async {
    // Validate delivery address
    final address = state.deliveryAddress;
    if (address == null) {
      state = state.copyWith(
        errorMessage: 'Please set your delivery address',
      );
      return Result.failure(
        CheckoutFailure.addressNotSet(),
      );
    }

    // Validate phone number
    final phone = state.phoneNumber.trim();
    if (phone.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter your phone number',
      );
      return Result.failure(
        CheckoutFailure.phoneNumberRequired(),
      );
    }

    final shopId = _shopId;
    final shopName = _shopName;
    final items = _cartItems;
    final subtotal = _subtotal;
    // Use currentUserProvider (sync) instead of authNotifierProvider (async)
    // to avoid empty user data when authNotifierProvider is auto-disposed.
    final authUser = ref.read(currentUserProvider);
    final userId = authUser?.uid ?? '';
    final userName = authUser?.displayName ?? '';
    final userEmail = authUser?.email ?? '';
    // Use the phone number the user entered (with Lebanon country code)
    final fullPhone = '$kLebanonCountryCode$phone';

    if (shopId == null || items.isEmpty) {
      state = state.copyWith(errorMessage: 'Cart is empty');
      return Result.failure(
        CartFailure.emptyCart(),
      );
    }

    state = state.copyWith(isPlacingOrder: true, errorMessage: null);

    final deliveryFee = state.deliveryFee;
    final total = subtotal + deliveryFee;

    final order = OrderModel(
      id: '', // Will be assigned by Firestore
      user: OrderUserInfo(
        id: userId,
        name: userName,
        email: userEmail,
        phone: fullPhone,
      ),
      shopId: shopId,
      shopName: shopName ?? '',
      items: List.from(items),
      deliveryAddress: address,
      deliveryTimeLabel: state.deliveryTimeLabel,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: 'Waiting Rider Confirmation',
    );

    final result = await _checkoutRepo.createOrder(order);

    return result.fold(
      onSuccess: (orderId) async {
        // Save the phone number back to the user's Firestore document
        // (best-effort — order was already created successfully)
        await _checkoutRepo.updateUserPhone(userId, fullPhone);

        // Clear the cart on successful order placement
        ref.read(cartNotifierProvider.notifier).clearCart();
        state = state.copyWith(
          isPlacingOrder: false,
          createdOrderId: orderId,
        );
        return Result.success(orderId);
      },
      onFailure: (failure) {
        state = state.copyWith(
          isPlacingOrder: false,
          errorMessage: failure.message,
        );
        return Result.failure(failure);
      },
    );
  }

}
