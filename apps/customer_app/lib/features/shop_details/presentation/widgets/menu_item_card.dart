import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/menu_item_model.dart';

/// A card displaying a single menu item.
///
/// Layout:
/// ```
/// ┌──────────────────────────────────────┐
/// │  ┌────────┐                          │
/// │  │ Image  │  Title                    │
/// │  │  80x80 │  Description line...      │
/// │  │        │  $12.99           [+ add] │
/// │  └────────┘                          │
/// └──────────────────────────────────────┘
/// ```
///
/// Tapping [+] calls [onAddTap], which the parent (ShopDetailsScreen) uses to
/// navigate to the [ItemDetailsScreen] with full item details and add-to-cart.
class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onAddTap;

  const MenuItemCard({
    super.key,
    required this.item,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Item Image ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildImage(),
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),

            // ── Item Details ────────────────────────────────────────
            // Expanded provides bounded width from the outer Row.
            // Column uses mainAxisSize.min so it sizes naturally to its
            // content — avoids vertical overflow from fixed height constraints.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    item.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Price + Add button row
                  Row(
                    children: [
                      // Price
                      Expanded(
                        child: Text(
                          item.formattedPrice,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add button — navigates to item details screen
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: () => onAddTap?.call(),
                          icon: const Icon(
                            Icons.add_circle_rounded,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Add ${item.name} to cart',
                        ),
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

  Widget _buildImage() {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.restaurant_rounded,
          size: 36,
          color: AppColors.textHint,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl!,
      fit: BoxFit.cover,
      width: 80,
      height: 80,
      placeholder: (_, __) => Container(
        color: AppColors.surface,
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.restaurant_rounded,
          size: 36,
          color: AppColors.textHint,
        ),
      ),
    );
  }

}
