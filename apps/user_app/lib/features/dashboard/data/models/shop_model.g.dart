// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopModel _$ShopModelFromJson(Map<String, dynamic> json) => _ShopModel(
  id: json['id'] as String,
  name: json['name'] as String,
  categoryId: json['categoryId'] as String,
  shortDescription: json['shortDescription'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  logoUrl: json['logoUrl'] as String,
  coverImageUrl: json['coverImageUrl'] as String?,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  deliveryTime: json['deliveryTime'] as String,
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
  minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
  isOpen: json['isOpen'] as bool? ?? true,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ShopModelToJson(_ShopModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'categoryId': instance.categoryId,
      'shortDescription': instance.shortDescription,
      'tags': instance.tags,
      'logoUrl': instance.logoUrl,
      'coverImageUrl': instance.coverImageUrl,
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'deliveryTime': instance.deliveryTime,
      'deliveryFee': instance.deliveryFee,
      'minOrderAmount': instance.minOrderAmount,
      'isOpen': instance.isOpen,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
