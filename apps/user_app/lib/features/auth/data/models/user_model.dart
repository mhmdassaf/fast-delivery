import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// User role enumeration
enum UserRole {
  @JsonValue('user')
  user,
  @JsonValue('rider')
  rider,
  @JsonValue('seller')
  seller,
  @JsonValue('admin')
  admin,
}

/// User model representing a user document in Firestore
@JsonSerializable()
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoURL;
  final UserRole role;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final List<String> fcmTokens;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.phoneNumber,
    this.photoURL,
    this.role = UserRole.user,
    this.isEmailVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isActive = true,
    this.fcmTokens = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Creates a UserModel from Firebase Auth user
  factory UserModel.fromFirebaseAuth({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    bool emailVerified = false,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? '',
      photoURL: photoURL,
      role: UserRole.user, // Default role
      isEmailVerified: emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      phoneNumber: phoneNumber,
      fcmTokens: const [],
    );
  }

  /// Creates a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    UserRole? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? isActive,
    List<String>? fcmTokens,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }

  /// Creates a copy with updated last login time
  UserModel copyWithLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// Converts to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'role': role.name,
      'emailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isActive': isActive,
      'fcmTokens': fcmTokens,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}