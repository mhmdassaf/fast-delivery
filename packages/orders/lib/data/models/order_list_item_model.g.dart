// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_list_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderListItemModel _$OrderListItemModelFromJson(Map<String, dynamic> json) =>
    _OrderListItemModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      deliveryAddressLine: json['deliveryAddressLine'] as String,
      total: (json['total'] as num).toDouble(),
      itemCount: (json['itemCount'] as num).toInt(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$OrderListItemModelToJson(_OrderListItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'shopId': instance.shopId,
      'shopName': instance.shopName,
      'deliveryAddressLine': instance.deliveryAddressLine,
      'total': instance.total,
      'itemCount': instance.itemCount,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.waitingRiderConfirmation: 'waitingRiderConfirmation',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.preparing: 'preparing',
  OrderStatus.outForDelivery: 'outForDelivery',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
