// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryAddressModel _$DeliveryAddressModelFromJson(
  Map<String, dynamic> json,
) => _DeliveryAddressModel(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  addressLine: json['addressLine'] as String,
  label: json['label'] as String? ?? 'Current Location',
);

Map<String, dynamic> _$DeliveryAddressModelToJson(
  _DeliveryAddressModel instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'addressLine': instance.addressLine,
  'label': instance.label,
};
