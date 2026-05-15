import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/shop_model.dart';

/// A modern shop card widget displaying shop information.
///
/// Uses a vertical layout with the image on top and details below.
/// Rendered in a single-column ListView so each card has full available width,
/// eliminating horizontal overflow issues entirely.
class ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback? onTap;

  const ShopCard({
    super.key,
    required this.shop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shop Image / Cover (full card width)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: shop.logoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.store_rounded,
                    size: AppDimens.iconXL,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),

            // Shop Info (full card width)
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + Open/Closed Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          shop.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingXS),
                      _OpenStatusBadge(isOpen: shop.isOpen),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingXS),

                  // Short description / tagline
                  if (shop.shortDescription != null &&
                      shop.shortDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.paddingXS),
                      child: Text(
                        shop.shortDescription!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: AppDimens.paddingXS),

                  // Rating + Delivery Info Row
                  // Full card width (~448dp) provides ~416dp content area,
                  // so all items fit comfortably with no overflow.
                  Row(
                    children: [
                      _RatingBadge(
                        rating: shop.rating,
                        ratingCount: shop.ratingCount,
                      ),
                      const SizedBox(width: AppDimens.paddingM),
                      _DeliveryInfo(
                        icon: Icons.access_time_rounded,
                        label: shop.deliveryTime,
                      ),
                      const Spacer(),
                      _DeliveryInfo(
                        icon: Icons.motorcycle_rounded,
                        label: shop.formattedDeliveryFee,
                      ),
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

/// Open/Closed status badge
class _OpenStatusBadge extends StatelessWidget {
  final bool isOpen;

  const _OpenStatusBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppDimens.radiusS),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOpen ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}

/// Star rating badge
class _RatingBadge extends StatelessWidget {
  final double rating;
  final int ratingCount;

  const _RatingBadge({required this.rating, required this.ratingCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: AppDimens.iconS,
          color: AppColors.warning,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '($ratingCount)',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Delivery info chip (time or fee)
class _DeliveryInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeliveryInfo({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppDimens.iconS, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
