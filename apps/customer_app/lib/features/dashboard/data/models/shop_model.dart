import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_model.freezed.dart';
part 'shop_model.g.dart';

/// Shop model representing a business/shop from Firestore
@freezed
abstract class ShopModel with _$ShopModel {
  const factory ShopModel({
    required String id,
    required String name,
    required String categoryId,
    String? shortDescription,
    @Default([]) List<String> tags,
    required String logoUrl,
    String? coverImageUrl,
    @Default(0.0) double rating,
    @Default(0) int ratingCount,
    required String deliveryTime,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double minOrderAmount,
    @Default(true) bool isOpen,
    String? address,
    double? latitude,
    double? longitude,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ShopModel;

  const ShopModel._();

  /// Create from Firestore document snapshot
  factory ShopModel.fromFirestore(
    DocumentSnapshot<Object?> snapshot,
  ) {
    final data = Map<String, dynamic>.from(snapshot.data() as Map);
    final geoPoint = data['location'] as GeoPoint?;
    return ShopModel(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      shortDescription: data['shortDescription'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      logoUrl: data['logoUrl'] as String? ?? '',
      coverImageUrl: data['coverImageUrl'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      deliveryTime: data['deliveryTime'] as String? ?? '30-45 min',
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (data['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      isOpen: data['isOpen'] as bool? ?? true,
      address: data['address'] as String?,
      latitude: geoPoint?.latitude,
      longitude: geoPoint?.longitude,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'categoryId': categoryId,
      'shortDescription': shortDescription,
      'tags': tags,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'minOrderAmount': minOrderAmount,
      'isOpen': isOpen,
      'address': address,
      if (latitude != null && longitude != null)
        'location': GeoPoint(latitude!, longitude!),
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Format delivery fee as string
  String get formattedDeliveryFee {
    if (deliveryFee == 0) return 'Free';
    return '\$${deliveryFee.toStringAsFixed(1)}';
  }

  /// Format rating as string
  String get formattedRating => rating.toStringAsFixed(1);

  /// Check if shop has a valid location
  bool get hasLocation => latitude != null && longitude != null;

  factory ShopModel.fromJson(Map<String, dynamic> json) =>
      _$ShopModelFromJson(json);
}
