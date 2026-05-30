import 'package:fast_delivery_core/errors/result.dart';

import '../datasources/checkout_datasource.dart';
import '../models/order_model.dart';

/// Repository for checkout / order operations.
///
/// Wraps [CheckoutDataSource] and can add business logic or caching later.
abstract class CheckoutRepository {
  /// Fetches shop delivery info: deliveryTime label and deliveryFee.
  Future<Result<Map<String, dynamic>>> getShopDeliveryInfo(String shopId);

  /// Creates a new order. Returns the order ID on success.
  Future<Result<String>> createOrder(OrderModel order);

  /// Fetches the user's phone number from their Firestore user document.
  Future<Result<String?>> getUserPhone(String userId);

  /// Updates the user's phone number in their Firestore user document.
  Future<Result<void>> updateUserPhone(String userId, String phone);
}

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutDataSource _dataSource;

  CheckoutRepositoryImpl({required CheckoutDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<Map<String, dynamic>>> getShopDeliveryInfo(String shopId) {
    return _dataSource.getShopDeliveryInfo(shopId);
  }

  @override
  Future<Result<String>> createOrder(OrderModel order) {
    return _dataSource.createOrder(order);
  }

  @override
  Future<Result<String?>> getUserPhone(String userId) {
    return _dataSource.getUserPhone(userId);
  }

  @override
  Future<Result<void>> updateUserPhone(String userId, String phone) {
    return _dataSource.updateUserPhone(userId, phone);
  }
}
