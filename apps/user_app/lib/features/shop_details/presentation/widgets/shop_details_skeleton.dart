import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Shimmer skeleton matching the ShopDetailsScreen layout.
///
/// Used during initial data loading to provide a smooth visual
/// transition while shop details and menu items are fetched.
class ShopDetailsSkeleton extends StatelessWidget {
  const ShopDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.background,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Cover skeleton ──────────────────────────────────
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 8),

            // ── Logo circle placeholder ─────────────────────────
            // (overlaps the cover, approximated)
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 12),

            // ── Name skeleton ───────────────────────────────────
            _buildLine(width: 180, height: 20),
            const SizedBox(height: 8),

            // ── Rating skeleton ─────────────────────────────────
            _buildLine(width: 120, height: 14),
            const SizedBox(height: 4),

            // ── Delivery info skeleton ──────────────────────────
            _buildLine(width: 160, height: 14),
            const SizedBox(height: 16),

            const Divider(height: 1),

            // ── Menu category skeletons ─────────────────────────
            ...List.generate(3, (index) => _buildCategorySkeleton()),
          ],
        ),
      ),
    );
  }

  Widget _buildLine({required double width, required double height}) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
        ),
      ),
    );
  }

  Widget _buildCategorySkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingM,
            ),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusS),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: SizedBox(
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Item card skeletons
          ...List.generate(
            2,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingM,
                vertical: 4,
              ),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusL),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
