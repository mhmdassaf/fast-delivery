import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_user_info.freezed.dart';
part 'order_user_info.g.dart';

/// Represents user data embedded inside an [OrderModel] document.
///
/// Stored in Firestore under `orders/{orderId}/user` with capital-letter keys:
/// ```json
/// {
///   "Id":    "abc123...",
///   "Name":  "John Doe",
///   "Email": "john@example.com",
///   "Phone": "+96170123456"
/// }
/// ```
@freezed
abstract class OrderUserInfo with _$OrderUserInfo {
  const factory OrderUserInfo({
    @JsonKey(name: 'Id') required String id,
    @JsonKey(name: 'Name') @Default('') String name,
    @JsonKey(name: 'Email') @Default('') String email,
    @JsonKey(name: 'Phone') String? phone,
  }) = _OrderUserInfo;

  const OrderUserInfo._();

  factory OrderUserInfo.fromJson(Map<String, dynamic> json) =>
      _$OrderUserInfoFromJson(json);

  /// Serialises to a Firestore-friendly map (capital-letter keys).
  Map<String, dynamic> toFirestore() => toJson();
}
