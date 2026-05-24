import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Shimmer loading skeleton for the orders list.
///
/// Shows 3-4 placeholder cards while orders are loading.
class OrderListLoading extends StatelessWidget {
  final int itemCount;

  const OrderListLoading({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.surface,
      child: Column(
        children: List.generate(itemCount, (_) => _buildSkeletonCard()),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop name skeleton
          _SkeletonLine(width: 180, height: 15),
          SizedBox(height: AppDimens.paddingXS),
          // Address skeleton
          _SkeletonLine(width: 240, height: 13),
          SizedBox(height: AppDimens.paddingXS),
          // Bottom row skeleton
          Row(
            children: [
              _SkeletonLine(width: 60, height: 13),
              Spacer(),
              _SkeletonLine(width: 50, height: 14),
              SizedBox(width: AppDimens.paddingS),
              _SkeletonLine(width: 40, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single shimmer line placeholder.
class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
