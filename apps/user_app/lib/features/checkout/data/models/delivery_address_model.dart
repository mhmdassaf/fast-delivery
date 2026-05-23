import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_address_model.freezed.dart';
part 'delivery_address_model.g.dart';

/// Represents a delivery address with geographic coordinates and a human-
/// readable address line.
@freezed
abstract class DeliveryAddressModel with _$DeliveryAddressModel {
  const factory DeliveryAddressModel({
    required double latitude,
    required double longitude,
    required String addressLine,
    @Default('Current Location') String label,
  }) = _DeliveryAddressModel;

  const DeliveryAddressModel._();

  /// Creates from Firestore document data.
  factory DeliveryAddressModel.fromMap(Map<String, dynamic> map) {
    return DeliveryAddressModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      addressLine: map['addressLine'] as String? ?? '',
      label: map['label'] as String? ?? 'Current Location',
    );
  }

  /// Converts to Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'addressLine': addressLine,
      'label': label,
    };
  }

  /// Converts to a GeoPoint for Firebase.
  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAddressModelFromJson(json);
}
