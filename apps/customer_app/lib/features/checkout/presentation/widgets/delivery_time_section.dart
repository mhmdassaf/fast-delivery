import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// A non-editable section showing the estimated delivery time fetched from
/// the shop's document.
class DeliveryTimeSection extends StatelessWidget {
  final String deliveryTimeLabel;
  final bool isLoading;

  const DeliveryTimeSection({
    super.key,
    required this.deliveryTimeLabel,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppColors.primary,
                size: AppDimens.iconM,
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Delivery Time',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (isLoading)
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    )
                  else
                    Text(
                      deliveryTimeLabel.isNotEmpty
                          ? deliveryTimeLabel
                          : 'As soon as possible',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
