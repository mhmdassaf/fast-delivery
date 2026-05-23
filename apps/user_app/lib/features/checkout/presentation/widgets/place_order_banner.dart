import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Fixed bottom banner showing the total amount and a [Place Order] button.
///
/// Designed to sit outside the scrollable body — similar visual pattern to
/// [ViewCartBanner] but adapted for the checkout flow.
class PlaceOrderBanner extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final bool isLoading;
  final bool isPlacingOrder;
  final VoidCallback? onPlaceOrder;

  const PlaceOrderBanner({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    this.isLoading = false,
    this.isPlacingOrder = false,
    this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final total = subtotal + deliveryFee;
    final textTheme = Theme.of(context).textTheme;
    final isEnabled = !isLoading && !isPlacingOrder && onPlaceOrder != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingM,
        AppDimens.paddingM,
        AppDimens.paddingM,
        AppDimens.paddingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Total on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Payment',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),

            // Place Order button
            Flexible(
              child: SizedBox(
                height: AppDimens.buttonHeightSmall,
                child: ElevatedButton(
                onPressed: isEnabled ? onPlaceOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onPrimary,
                  foregroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.onPrimary.withValues(alpha: 0.5),
                  disabledForegroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingL,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                child: isPlacingOrder
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      )
                    : const Text('Place Order'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
