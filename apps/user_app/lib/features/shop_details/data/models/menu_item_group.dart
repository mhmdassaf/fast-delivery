import 'menu_item_model.dart';

/// Groups [MenuItemModel]s by their [MenuItemModel.category].
///
/// Used client-side after fetching all items for a shop
/// to display the menu organised by category sections.
class MenuItemGroup {
  final String category;
  final List<MenuItemModel> items;

  const MenuItemGroup({
    required this.category,
    required this.items,
  });
}
