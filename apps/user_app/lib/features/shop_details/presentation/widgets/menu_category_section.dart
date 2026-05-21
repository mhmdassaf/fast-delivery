import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/menu_item_group.dart';
import '../../data/models/menu_item_model.dart';
import 'menu_item_card.dart';

/// Displays a menu category header followed by its item cards.
///
/// Layout:
/// ```
/// ── Category Name ─────────────────
/// ┌─ MenuItemCard ────────────────┐
/// │ ...                           │
/// └───────────────────────────────┘
/// ┌─ MenuItemCard ────────────────┐
/// │ ...                           │
/// └───────────────────────────────┘
/// ```
class MenuCategorySection extends StatelessWidget {
  final MenuItemGroup group;

  /// Called when the [+] button on a menu item is tapped.
  /// Receives the tapped [MenuItemModel] so the parent can navigate.
  final void Function(MenuItemModel item)? onItemAddTap;

  const MenuCategorySection({
    super.key,
    required this.group,
    this.onItemAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Category Header ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingM,
            AppDimens.paddingM,
            AppDimens.paddingM,
            AppDimens.paddingS,
          ),
          child: Row(
            children: [
              Text(
                group.category,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.textHint.withValues(alpha: 0.3),
                ),
              ),
              if (group.items.length > 1) ...[
                const SizedBox(width: 8),
                Text(
                  '${group.items.length}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // ── Item Cards ──────────────────────────────────────────────
        ...group.items.map(
          (item) => MenuItemCard(
            item: item,
            onAddTap: onItemAddTap != null
                ? () => onItemAddTap!(item)
                : null,
          ),
        ),
      ],
    );
  }
}
