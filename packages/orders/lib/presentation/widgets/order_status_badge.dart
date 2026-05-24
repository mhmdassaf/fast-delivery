import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// A colored badge showing the order status.
///
/// Color mapping:
/// - Active statuses (Waiting, Confirmed, Preparing, Out for Delivery) → Amber/Orange
/// - Delivered → Green
/// - Cancelled → Red
class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  /// Returns the display color for a given status.
  static Color _colorForStatus(String status) {
    switch (status) {
      case 'Delivered':
        return AppColors.success;
      case 'Cancelled':
        return AppColors.error;
      default:
        // All active/pending statuses
        return AppColors.warning;
    }
  }

  /// Returns a lighter background color for the badge.
  static Color _bgForStatus(String status) {
    switch (status) {
      case 'Delivered':
        return AppColors.successLight;
      case 'Cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _bgForStatus(status);
    final fgColor = _colorForStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingXS / 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}
