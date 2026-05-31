import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fast_delivery_orders/data/models/status_history_entry.dart';
import 'package:fast_delivery_orders/domain/order_status.dart';

import '../../../cart/data/models/cart_item_model.dart';
import 'delivery_address_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

/// Represents a customer order placed from the shopping cart.
///
/// Stored in Firestore under `orders/{orderId}`. User details are stored as
/// top-level fields (`customerId`, `customerName`, `customerPhone`) for simple querying.
@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String shopId,
    required String shopName,
    required List<CartItemModel> items,
    required DeliveryAddressModel deliveryAddress,
    required String deliveryTimeLabel,
    required double subtotal,
    required double deliveryFee,
    required double total,
    @Default(OrderStatus.waitingRiderConfirmation) OrderStatus status,
    @Default([]) List<StatusHistoryEntry> statusHistory,
    DateTime? createdAt,
  }) = _OrderModel;

  const OrderModel._();

  /// Creates from a Firestore document snapshot.
  factory OrderModel.fromFirestore(DocumentSnapshot<Object?> snapshot) {
    final data = Map<String, dynamic>.from(snapshot.data() as Map);
    final itemsData = List<Map<String, dynamic>>.from(data['items'] ?? []);
    final addressData =
        Map<String, dynamic>.from(data['deliveryAddress'] ?? {});

    return OrderModel(
      id: snapshot.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      shopId: data['shopId'] as String? ?? '',
      shopName: data['shopName'] as String? ?? '',
      items: itemsData.map((e) => CartItemModel.fromJson(e)).toList(),
      deliveryAddress: DeliveryAddressModel.fromMap(addressData),
      deliveryTimeLabel: data['deliveryTimeLabel'] as String? ?? '',
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.fromFirestore(data['status']),
      statusHistory: _parseStatusHistory(data['statusHistory']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Parses the `statusHistory` array from the Firestore document.
  ///
  /// Returns an empty list if the field is missing, null, or contains
  /// unparseable entries (individual bad entries are skipped).
  static List<StatusHistoryEntry> _parseStatusHistory(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => StatusHistoryEntry.fromMap(e))
        .toList();
  }

  /// Converts to a Firestore document.
  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'shopId': shopId,
      'shopName': shopName,
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'deliveryTimeLabel': deliveryTimeLabel,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status.toFirestore(),
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
