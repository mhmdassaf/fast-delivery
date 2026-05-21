import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

/// Represents a single item in the user's shopping cart.
///
/// Persisted to local storage via shared_preferences using JSON serialization.
/// Created when a user adds a menu item from the shop details screen.
@freezed
abstract class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    /// Unique identifier (maps to the menu item ID in Firestore).
    required String id,

    /// The shop this item belongs to.
    required String shopId,

    /// Shop display name (cached for cart display without extra fetches).
    required String shopName,

    /// Menu item display name.
    required String name,

    /// Optional item image URL.
    String? imageUrl,

    /// Unit price in USD.
    @Default(0.0) double price,

    /// Quantity of this item (minimum 1).
    @Default(1) int quantity,

    /// User-provided special instructions (e.g. "no onions").
    @Default('') String specialInstructions,
  }) = _CartItemModel;

  const CartItemModel._();

  /// Total cost for this line item (price × quantity).
  double get totalPrice => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
