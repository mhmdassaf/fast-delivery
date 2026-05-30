import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../../dashboard/data/models/shop_model.dart';

/// Displays the shop's cover image, logo, name, rating, and delivery info.
///
/// Layout (vertical):
/// ```
/// ┌──────────────────────────────────┐
/// │   [Cover Image with gradient]    │  ← 200dp height
/// │        [Logo overlay]            │  ← circular, 80dp
/// │   Shop Name                      │
/// │   ★ 4.5 (234 ratings)            │
/// │   🟢 Open  •  25-35 min  • $2.99 │
/// └──────────────────────────────────┘
/// ```
class ShopHeaderSection extends StatelessWidget {
  final ShopModel shop;

  const ShopHeaderSection({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      children: [
        // ── Cover Image + Logo ──────────────────────────────────────
        _CoverSection(shop: shop),

        // ── Shop Name ───────────────────────────────────────────────
        // Logo extends 40px below cover (Offset(0,40) on an 80×80 circle).
        // Push name below the logo with (40 + 8) = 48px top padding.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingM,
            AppDimens.paddingXL + AppDimens.paddingM, // 32 + 16 = 48
            AppDimens.paddingM,
            0,
          ),
          child: Text(
            shop.name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ── Rating Row ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingM,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
              Text(
                shop.formattedRating,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (shop.ratingCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '(${_formatRatingCount(shop.ratingCount)})',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ── Delivery Info Row ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingM,
            0,
            AppDimens.paddingM,
            AppDimens.paddingM,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Open / Closed badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: shop.isOpen
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  shop.isOpen ? 'Open' : 'Closed',
                  style: textTheme.labelSmall?.copyWith(
                    color: shop.isOpen
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Delivery time
              Flexible(
                child: Text(
                  shop.deliveryTime,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '•',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(width: 4),
              // Delivery fee
              Flexible(
                child: Text(
                  shop.formattedDeliveryFee,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  /// Format rating count for display (e.g., 1234 → "1.2K").
  static String _formatRatingCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// The cover image with gradient overlay and circular logo.
class _CoverSection extends StatelessWidget {
  final ShopModel shop;

  const _CoverSection({required this.shop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Stack(
        children: [
          // Cover image
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: shop.coverImageUrl ?? shop.logoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.surface,
              ),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.store_rounded,
                  size: 64,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ),
          // Logo at bottom-center
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, 40),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.background,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onBackground.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: shop.logoUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.surface,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.store_rounded,
                          size: 36,
                          color: AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
