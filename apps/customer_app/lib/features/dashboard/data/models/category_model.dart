import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

/// Category model representing a shop category from Firestore
@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String icon,
    String? imageUrl,
    @Default(0) int order,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CategoryModel;

  const CategoryModel._();

  /// Create from Firestore document snapshot
  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Object?> snapshot,
  ) {
    final data = Map<String, dynamic>.from(snapshot.data() as Map);
    return CategoryModel(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      icon: data['icon'] as String? ?? 'store',
      imageUrl: data['imageUrl'] as String?,
      order: (data['order'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'imageUrl': imageUrl,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}
