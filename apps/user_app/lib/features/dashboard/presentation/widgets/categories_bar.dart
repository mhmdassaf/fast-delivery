import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/category_model.dart';

/// Horizontal scrollable category filter bar.
///
/// Displays category chips horizontally. The first item is always "All".
/// Supports dynamic categories from backend.
class CategoriesBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final bool isLoading;

  const CategoriesBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
        children: [
          // "All" category chip
          _CategoryChip(
            label: 'All',
            icon: Icons.explore_rounded,
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: AppDimens.paddingS),

          // Dynamic category chips
          if (isLoading)
            ...List.generate(
              5,
              (index) => _CategoryChipShimmer(key: ValueKey('shimmer_$index')),
            )
          else
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: AppDimens.paddingS),
                child: _CategoryChip(
                  label: category.name,
                  icon: _iconFromName(category.icon),
                  isSelected: selectedCategoryId == category.id,
                  onTap: () => onCategorySelected(category.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Map icon name string to Icons constant
  IconData _iconFromName(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
      case 'restaurants':
        return Icons.restaurant_rounded;
      case 'bakery':
        return Icons.bakery_dining_rounded;
      case 'butcher':
        return Icons.egg_rounded;
      case 'supermarket':
        return Icons.local_grocery_store_rounded;
      case 'vegetables':
      case 'vegetable':
        return Icons.eco_rounded;
      case 'crepe':
        return Icons.lunch_dining_rounded;
      case 'sweets':
      case 'dessert':
        return Icons.cake_rounded;
      case 'pharmacy':
        return Icons.local_pharmacy_rounded;
      default:
        return Icons.store_rounded;
    }
  }
}

/// Single category chip widget
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimens.iconS,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimens.paddingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for category chips during loading
class _CategoryChipShimmer extends StatelessWidget {
  const _CategoryChipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: AppDimens.paddingS),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
      ),
    );
  }
}
