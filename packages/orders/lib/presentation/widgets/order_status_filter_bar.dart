import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../domain/order_list_providers.dart';

/// Horizontal scrollable status filter chip bar.
///
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
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
        children: StatusFilterOption.values.map((option) {
          final isSelected = selectedFilter == option.filterValue;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimens.paddingS),
            child: FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(option.filterValue),
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusRound),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
