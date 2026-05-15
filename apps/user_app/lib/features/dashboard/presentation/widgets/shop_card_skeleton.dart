import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Shimmer skeleton loader for the vertical ShopCard layout.
///
/// Matches the vertical card layout: image placeholder on top,
/// content placeholders below.
class ShopCardSkeleton extends StatelessWidget {
  const ShopCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.background,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          side: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder (full card width)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusL),
                  ),
                ),
              ),
            ),

            // Content placeholders (full card width)
            Padding(
              padding: EdgeInsets.all(AppDimens.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name placeholder + badge
                  Row(
                    children: [
                      _SkeletonBar(width: 180, height: 16),
                      Spacer(),
                      _SkeletonBar(width: 44, height: 22),
                    ],
                  ),
                  SizedBox(height: AppDimens.paddingS),

                  // Description placeholder
                  _SkeletonBar(width: 240, height: 12),
                  SizedBox(height: AppDimens.paddingS + 4),

                  // Rating + Delivery info row
                  Row(
                    children: [
                      _SkeletonBar(width: 80, height: 12),
                      SizedBox(width: AppDimens.paddingM),
                      _SkeletonBar(width: 70, height: 12),
                      Spacer(),
                      _SkeletonBar(width: 50, height: 12),
                    ],
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

/// A small shimmer bar for skeleton loading.
class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
    );
  }
}
