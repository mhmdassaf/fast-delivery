import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../domain/order_list_providers.dart';
import '../../domain/order_status.dart';

/// A colored badge showing the order status description.
///
/// Color mapping:
/// - Active statuses → Amber/Orange
/// - Delivered → Green
/// - Cancelled → Red
class OrderStatusBadge extends ConsumerWidget {
  final OrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  static Color _colorForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  static Color _bgForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return AppColors.successLight;
      case OrderStatus.cancelled:
        return AppColors.errorLight;
      default:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(orderStatusDescriptionOverridesProvider);
    final description = overrides.when(
      data: (data) => status.resolveDescription(data),
      loading: () => status.description,
      error: (_, __) => status.description,
    );

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
        description,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}
