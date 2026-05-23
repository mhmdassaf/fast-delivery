/// Base failure class for error handling
sealed class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Authentication related failures
final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidEmail() =>
      const AuthFailure(message: 'Please enter a valid email address');

  factory AuthFailure.weakPassword() =>
      const AuthFailure(message: 'Password must be at least 8 characters');

  factory AuthFailure.emailAlreadyInUse() =>
      const AuthFailure(message: 'This email is already registered');

  factory AuthFailure.wrongPassword() =>
      const AuthFailure(message: 'Incorrect password. Please try again');

  factory AuthFailure.userNotFound() =>
      const AuthFailure(message: 'No account found with this email');

  factory AuthFailure.userDisabled() =>
      const AuthFailure(message: 'This account has been disabled');

  factory AuthFailure.tooManyRequests() =>
      const AuthFailure(message: 'Too many attempts. Please try again later');

  factory AuthFailure.networkError() =>
      const AuthFailure(message: 'Network error. Please check your connection');

  factory AuthFailure.unknown([String? message]) =>
      AuthFailure(message: message ?? 'An unknown error occurred');

  factory AuthFailure.invalidCredential() =>
      const AuthFailure(message: 'Invalid credentials provided');
}

/// Validation failures
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Network related failures
final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network error occurred', super.code});
}

/// Server related failures
final class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

/// Cache related failures
final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code});
}

/// Dashboard related failures
final class DashboardFailure extends Failure {
  const DashboardFailure({required super.message, super.code});

  factory DashboardFailure.fetchFailed([String? message]) =>
      DashboardFailure(message: message ?? 'Failed to load shops');

  factory DashboardFailure.fetchCategoriesFailed([String? message]) =>
      DashboardFailure(message: message ?? 'Failed to load categories');
}

/// Shop details related failures
final class ShopDetailsFailure extends Failure {
  const ShopDetailsFailure({required super.message, super.code});

  factory ShopDetailsFailure.fetchShopFailed([String? message]) =>
      ShopDetailsFailure(message: message ?? 'Failed to load shop details');

  factory ShopDetailsFailure.fetchMenuFailed([String? message]) =>
      ShopDetailsFailure(message: message ?? 'Failed to load menu items');
}

/// Cart related failures
final class CartFailure extends Failure {
  const CartFailure({required super.message, super.code});

  factory CartFailure.emptyCart() =>
      const CartFailure(message: 'Cart is empty');

  factory CartFailure.addToCartFailed([String? message]) =>
      CartFailure(message: message ?? 'Failed to add item to cart');

  factory CartFailure.persistFailed() =>
      const CartFailure(message: 'Failed to save cart data');
}

/// Checkout / order related failures
final class CheckoutFailure extends Failure {
  const CheckoutFailure({required super.message, super.code});

  factory CheckoutFailure.addressNotSet() =>
      const CheckoutFailure(message: 'Please set your delivery address');

  factory CheckoutFailure.phoneNumberRequired() =>
      const CheckoutFailure(message: 'Please enter your phone number');

  factory CheckoutFailure.createOrderFailed([String? message]) =>
      CheckoutFailure(message: message ?? 'Failed to place order');

  factory CheckoutFailure.locationFailed([String? message]) =>
      CheckoutFailure(message: message ?? 'Failed to get your location');

  factory CheckoutFailure.shopInfoFailed([String? message]) =>
      CheckoutFailure(message: message ?? 'Failed to load shop information');

  factory CheckoutFailure.phoneUpdateFailed([String? message]) =>
      CheckoutFailure(message: message ?? 'Failed to update phone number');
}
