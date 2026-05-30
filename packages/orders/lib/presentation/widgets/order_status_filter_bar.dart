import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../domain/order_list_providers.dart';

/// Horizontal scrollable status filter chip bar.
///
/// Visually matches the dashboard's [CategoriesBar] chip design.
/// Options: All | Active | Completed | Cancelled
class OrderStatusFilterBar extends StatelessWidget {
  final String? selectedFilter;
  final ValueChanged<String?> onFilterSelected;

  const OrderStatusFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
        children: StatusFilterOption.values.map((option) {
          final isSelected = selectedFilter == option.filterValue;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimens.paddingS),
            child: _StatusChip(
              label: option.label,
              icon: option.icon,
              isSelected: isSelected,
              onTap: () => onFilterSelected(option.filterValue),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Single status filter chip matching the dashboard category chip design.
class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusChip({
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
