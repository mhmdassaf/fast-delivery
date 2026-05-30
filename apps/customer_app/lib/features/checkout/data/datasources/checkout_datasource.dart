import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';

import '../models/order_model.dart';

/// Data source interface for checkout / order operations.
abstract class CheckoutDataSource {
  /// Fetches a shop's delivery info (deliveryTime, deliveryFee) by shop ID.
  Future<Result<Map<String, dynamic>>> getShopDeliveryInfo(String shopId);

  /// Creates a new order document in Firestore.
  /// Returns the generated document ID on success.
  Future<Result<String>> createOrder(OrderModel order);

  /// Fetches the user's phone number from their Firestore user document.
  /// Returns null if no phone number is stored.
  Future<Result<String?>> getUserPhone(String userId);

  /// Updates the user's phone number in their Firestore user document.
  Future<Result<void>> updateUserPhone(String userId, String phone);
}

/// Implementation of [CheckoutDataSource] using Firebase Firestore.
class CheckoutDataSourceImpl implements CheckoutDataSource {
  final FirebaseFirestore _firestore;

  CheckoutDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<Map<String, dynamic>>> getShopDeliveryInfo(
    String shopId,
  ) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();

      if (!doc.exists) {
        return Result.failure(
          CheckoutFailure.shopInfoFailed('Shop not found'),
        );
      }

      final data = doc.data()!;
      return Result.success({
        'deliveryTime': data['deliveryTime'] as String? ?? '30-45 min',
        'deliveryFee': (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      });
    } on FirebaseException catch (e) {
      return Result.failure(
        CheckoutFailure.phoneUpdateFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        CheckoutFailure.phoneUpdateFailed(e.toString()),
      );
    }
  }

  @override
  Future<Result<String>> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection('orders').add(
            order.toFirestore(),
          );
      return Result.success(docRef.id);
    } on FirebaseException catch (e) {
      return Result.failure(
        CheckoutFailure.createOrderFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        CheckoutFailure.createOrderFailed(e.toString()),
      );
    }
  }

  @override
  Future<Result<String?>> getUserPhone(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return Result.success(null);

      final phone = doc.data()?['phoneNumber'] as String?;
      return Result.success(phone);
    } on FirebaseException {
      return Result.success(null); // Silently fail — phone is optional
    } catch (_) {
      return Result.success(null);
    }
  }

  @override
  Future<Result<void>> updateUserPhone(String userId, String phone) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'phoneNumber': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        CheckoutFailure.createOrderFailed(e.message),
      );
    } catch (e) {
      return Result.failure(
        CheckoutFailure.createOrderFailed(e.toString()),
      );
    }
  }
}
