import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Displays the order financial summary: subtotal, delivery fee, and total.
class OrderSummarySection extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;

  const OrderSummarySection({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = subtotal + deliveryFee;

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
        child: Column(
          children: [
            // SubTotal
            _SummaryRow(
              label: 'SubTotal',
              value: '\$${subtotal.toStringAsFixed(2)}',
              valueStyle: textTheme.bodyMedium?.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),

            // Delivery Fee
            _SummaryRow(
              label: 'Delivery Fee',
              value: deliveryFee == 0
                  ? 'Free'
                  : '\$${deliveryFee.toStringAsFixed(2)}',
              valueStyle: textTheme.bodyMedium?.copyWith(
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),

            // Divider
            const Divider(height: 1, color: AppColors.surfaceVariant),
            const SizedBox(height: AppDimens.paddingS),

            // Total
            _SummaryRow(
              label: 'Total',
              value: '\$${total.toStringAsFixed(2)}',
              valueStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single row within the order summary: label on the left, value on the
/// right.
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: AppDimens.paddingS),
        Flexible(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
