import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_list_item_model.freezed.dart';
part 'order_list_item_model.g.dart';

/// Lightweight order model for list display.
///
/// Contains only the fields needed for the orders list screen,
/// avoiding the full cart items payload.
///
/// Firestore document structure (`orders/{orderId}`):
/// ```json
/// {
///   "userId": "abc123",
///   "userName": "John Doe",
///   "userPhone": "+96170123456",
///   "shopId": "shop_xyz",
///   "shopName": "Pizza Palace",
///   "deliveryAddress": { "addressLine": "123 Main St", ... },
///   "items": [ ... ],
///   "subtotal": 12.99,
///   "deliveryFee": 2.50,
///   "total": 15.49,
///   "status": "Waiting Rider Confirmation",
///   "createdAt": Timestamp
/// }
/// ```
@freezed
abstract class OrderListItemModel with _$OrderListItemModel {
  const factory OrderListItemModel({
    required String id,
    required String userId,
    required String userName,
    required String shopId,
    required String shopName,
    required String deliveryAddressLine,
    required double total,
    required int itemCount,
    required String status,
    required DateTime createdAt,
  }) = _OrderListItemModel;

  const OrderListItemModel._();

  /// Creates from a Firestore document snapshot.
  factory OrderListItemModel.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    final data = Map<String, dynamic>.from(snapshot.data() as Map);
    final addressData =
        Map<String, dynamic>.from(data['deliveryAddress'] ?? {});
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);

    return OrderListItemModel(
      id: snapshot.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      deliveryAddressLine:
          addressData['addressLine'] as String? ?? 'No address',
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: itemsData.length,
      status: data['status'] as String? ?? 'Waiting Rider Confirmation',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory OrderListItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderListItemModelFromJson(json);
}
