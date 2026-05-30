import '../../../shop_details/data/models/menu_item_model.dart';

/// Arguments passed to the ItemDetailsScreen via GoRouter `extra`.
///
/// Bundles the [MenuItemModel] with its shop context (shopId and shopName)
/// since the menu item model itself does not store which shop it belongs to.
class ItemDetailArgs {
  final MenuItemModel item;
  final String shopId;
  final String shopName;

  const ItemDetailArgs({
    required this.item,
    required this.shopId,
    required this.shopName,
  });
}
