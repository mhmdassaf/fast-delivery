// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_user_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrderUserInfo _$OrderUserInfoFromJson(Map<String, dynamic> json) =>
    _OrderUserInfo(
      id: json['Id'] as String,
      name: json['Name'] as String? ?? '',
      email: json['Email'] as String? ?? '',
      phone: json['Phone'] as String?,
    );

Map<String, dynamic> _$OrderUserInfoToJson(_OrderUserInfo instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Email': instance.email,
      'Phone': instance.phone,
    };
