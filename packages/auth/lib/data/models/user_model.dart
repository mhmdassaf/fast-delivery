import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User role enumeration
@JsonEnum()
enum UserRole {
  @JsonValue('customer')
  customer,
  @JsonValue('rider')
  rider,
  @JsonValue('seller')
  seller,
  @JsonValue('admin')
  admin,
}

/// User model representing a user document in Firestore
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    @Default('') String displayName,
    String? phoneNumber,
    String? photoURL,
    @Default(UserRole.customer) UserRole role,
    @Default(false) bool isEmailVerified,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    @Default(true) bool isActive,
    @Default([]) List<String> fcmTokens,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

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
      role: UserRole.customer, // Default role
      isEmailVerified: emailVerified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      phoneNumber: phoneNumber,
      fcmTokens: const [],
    );
  }
}

/// Extension methods for UserModel
extension UserModelX on UserModel {
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
}
