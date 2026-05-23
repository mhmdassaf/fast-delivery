import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../cart/data/models/cart_item_model.dart';
import 'delivery_address_model.dart';
import 'order_user_info.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Represents a customer order placed from the shopping cart.
///
/// Stored in Firestore under `orders/{orderId}`. User data is nested under
/// a `user` sub-object with capital-letter keys (Id, Name, Email, Phone).
@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required OrderUserInfo user,
    required String shopId,
    required String shopName,
    required List<CartItemModel> items,
    required DeliveryAddressModel deliveryAddress,
    required String deliveryTimeLabel,
    required double subtotal,
    required double deliveryFee,
    required double total,
    @Default('Waiting Rider Confirmation') String status,
    DateTime? createdAt,
  }) = _OrderModel;

  const OrderModel._();

  /// Creates from a Firestore document snapshot.
  factory OrderModel.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    final data = Map<String, dynamic>.from(snapshot.data() as Map);
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final addressData =
        Map<String, dynamic>.from(data['deliveryAddress'] ?? {});
    final userData = Map<String, dynamic>.from(data['user'] ?? {});

    return OrderModel(
      id: snapshot.id,
      user: OrderUserInfo.fromJson(userData),
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      items: itemsData.map((e) => CartItemModel.fromJson(e)).toList(),
      deliveryAddress: DeliveryAddressModel.fromMap(addressData),
      deliveryTimeLabel: data['deliveryTimeLabel'] as String? ?? '',
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'Waiting Rider Confirmation',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'user': user.toFirestore(),
      'shopId': shopId,
      'shopName': shopName,
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'deliveryTimeLabel': deliveryTimeLabel,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
