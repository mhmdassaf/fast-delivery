// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String? ?? '',
  phoneNumber: json['phoneNumber'] as String?,
  photoURL: json['photoURL'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  lastLoginAt: json['lastLoginAt'] == null
      ? null
      : DateTime.parse(json['lastLoginAt'] as String),
  isActive: json['isActive'] as bool? ?? true,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'phoneNumber': instance.phoneNumber,
  'photoURL': instance.photoURL,
  'role': _$UserRoleEnumMap[instance.role]!,
  'isEmailVerified': instance.isEmailVerified,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
  'isActive': instance.isActive,
  'fcmTokens': instance.fcmTokens,
};

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.rider: 'rider',
  UserRole.seller: 'seller',
  UserRole.admin: 'admin',
};
