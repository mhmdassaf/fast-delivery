import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/order_status.dart';

part 'order_list_item_model.freezed.dart';
part 'order_list_item_model.g.dart';

/// Lightweight order model for list display.
///
/// Contains only the fields needed for the orders list screen,
/// avoiding the full cart items payload.
@freezed
abstract class OrderListItemModel with _$OrderListItemModel {
  const factory OrderListItemModel({
    required String id,
    required String customerId,
    required String customerName,
    required String shopId,
    required String shopName,
    required String deliveryAddressLine,
    required double total,
    required int itemCount,
    required OrderStatus status,
    required DateTime createdAt,
  }) = _OrderListItemModel;

  const OrderListItemModel._();

  factory OrderListItemModel.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    final data = Map<String, dynamic>.from(snapshot.data() as Map);
    final addressData =
        Map<String, dynamic>.from(data['deliveryAddress'] ?? {});
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);

    return OrderListItemModel(
      id: snapshot.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      deliveryAddressLine:
          addressData['addressLine'] as String? ?? 'No address',
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      itemCount: itemsData.length,
      status: OrderStatus.fromFirestore(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory OrderListItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderListItemModelFromJson(json);
}
