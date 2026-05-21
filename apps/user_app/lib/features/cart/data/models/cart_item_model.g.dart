// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItemModel _$CartItemModelFromJson(Map<String, dynamic> json) =>
    _CartItemModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      specialInstructions: json['specialInstructions'] as String? ?? '',
    );

Map<String, dynamic> _$CartItemModelToJson(_CartItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'shopId': instance.shopId,
      'shopName': instance.shopName,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'quantity': instance.quantity,
      'specialInstructions': instance.specialInstructions,
    };
