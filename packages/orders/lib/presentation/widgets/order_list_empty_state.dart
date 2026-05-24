import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Empty state widget shown when there are no orders.
class OrderListEmptyState extends StatelessWidget {
  final bool hasActiveFilter;

  const OrderListEmptyState({super.key, this.hasActiveFilter = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActiveFilter
                  ? Icons.filter_list_off_rounded
                  : Icons.receipt_long_outlined,
              size: 72,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              hasActiveFilter
                  ? 'No orders found'
                  : 'No orders yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              hasActiveFilter
                  ? 'Try changing the status filter'
                  : 'Your orders will appear here once you place one',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
