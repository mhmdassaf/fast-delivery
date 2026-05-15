// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_filter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopFilterModel _$ShopFilterModelFromJson(Map<String, dynamic> json) =>
    _ShopFilterModel(
      minRating: (json['minRating'] as num?)?.toDouble(),
      maxDeliveryFee: (json['maxDeliveryFee'] as num?)?.toDouble(),
      openNow: json['openNow'] as bool? ?? true,
      maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble(),
      sortBy:
          $enumDecodeNullable(_$SortOptionEnumMap, json['sortBy']) ??
          SortOption.rating,
    );

Map<String, dynamic> _$ShopFilterModelToJson(_ShopFilterModel instance) =>
    <String, dynamic>{
      'minRating': instance.minRating,
      'maxDeliveryFee': instance.maxDeliveryFee,
      'openNow': instance.openNow,
      'maxDistanceKm': instance.maxDistanceKm,
      'sortBy': _$SortOptionEnumMap[instance.sortBy]!,
    };

const _$SortOptionEnumMap = {
  SortOption.rating: 'rating',
  SortOption.deliveryFee: 'deliveryFee',
  SortOption.distance: 'distance',
  SortOption.newest: 'newest',
};
