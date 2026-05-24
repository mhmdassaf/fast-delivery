import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/order_list_item_model.dart';
import 'order_status_badge.dart';

/// Card displaying a single order in the orders list.
///
/// Shows: shop name, delivery address line, item count, total price,
/// status badge, and relative time.
class OrderCard extends StatelessWidget {
  final OrderListItemModel order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final timeAgo = _formatTimeAgo(order.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            padding: const EdgeInsets.all(AppDimens.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Shop name + Status badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.shopName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingS),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingXS),

                // Row 2: Delivery address
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.deliveryAddressLine,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.paddingXS),

                // Row 3: Item count + Total + Time
                Row(
                  children: [
                    // Item count
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _itemCountLabel(order.itemCount),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),

                    // Total price
                    Text(
                      currencyFormat.format(order.total),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingS),

                    // Time ago
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _itemCountLabel(int count) {
    if (count == 1) return '1 item';
    return '$count items';
  }

  /// Formats a [DateTime] as a human-readable relative time string.
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }
}
