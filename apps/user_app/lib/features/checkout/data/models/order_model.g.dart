// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => _OrderModel(
  id: json['id'] as String,
  user: OrderUserInfo.fromJson(json['user'] as Map<String, dynamic>),
  shopId: json['shopId'] as String,
  shopName: json['shopName'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryAddress: DeliveryAddressModel.fromJson(
    json['deliveryAddress'] as Map<String, dynamic>,
  ),
  deliveryTimeLabel: json['deliveryTimeLabel'] as String,
  subtotal: (json['subtotal'] as num).toDouble(),
  deliveryFee: (json['deliveryFee'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  status: json['status'] as String? ?? 'Waiting Rider Confirmation',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$OrderModelToJson(_OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'shopId': instance.shopId,
      'shopName': instance.shopName,
      'items': instance.items,
      'deliveryAddress': instance.deliveryAddress,
      'deliveryTimeLabel': instance.deliveryTimeLabel,
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'total': instance.total,
      'status': instance.status,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
