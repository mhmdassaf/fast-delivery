import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_item_model.freezed.dart';
part 'menu_item_model.g.dart';

/// Model representing a single menu item within a shop.
///
/// Items are stored in the subcollection `shops/{shopId}/menu_items/{itemId}`
/// and are grouped client-side by their [category] field.
@freezed
abstract class MenuItemModel with _$MenuItemModel {
  const factory MenuItemModel({
    required String id,
    required String name,
    String? description,
    String? imageUrl,
    @Default(0.0) double price,
    required String category,
    @Default(true) bool isAvailable,
    @Default(0) int order,
    @Default(false) bool isPopular,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MenuItemModel;

  const MenuItemModel._();

  /// Create a [MenuItemModel] from a Firestore [DocumentSnapshot].
  factory MenuItemModel.fromFirestore(
    DocumentSnapshot<Object?> snapshot,
  ) {
    final data = snapshot.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return MenuItemModel(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'Other',
      isAvailable: data['isAvailable'] as bool? ?? true,
      order: (data['order'] as num?)?.toInt() ?? 0,
      isPopular: data['isPopular'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert this model to a Firestore document map.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'order': order,
      'isPopular': isPopular,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Format price in USD (always USD per app requirements).
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);
}
