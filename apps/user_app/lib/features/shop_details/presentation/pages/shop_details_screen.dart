import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../../../features/cart/data/models/item_detail_args.dart';
import '../../domain/providers/shop_details_providers.dart';
import '../widgets/menu_category_section.dart';
import '../widgets/shop_details_error_state.dart';
import '../widgets/shop_details_skeleton.dart';
import '../widgets/shop_header_section.dart';

/// Displays the details of a shop and its menu items, organised by category.
///
/// Receives a [shopId] parameter from the GoRouter `/shop/:shopId` route.
/// Uses the [shopDetailsNotifierProvider] scoped to this specific shop.
class ShopDetailsScreen extends ConsumerWidget {
  final String shopId;

  const ShopDetailsScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopDetailsNotifierProvider(shopId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.shop?.name ?? 'Shop Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ShopDetailsState state,
  ) {
    // ── Loading State ──────────────────────────────────────────────
    if (state.isLoading || state.shop == null && !state.hasError) {
      return const ShopDetailsSkeleton();
    }

    // ── Error State (no data) ──────────────────────────────────────
    if (state.hasError && state.shop == null) {
      return ShopDetailsErrorState(
        message: state.errorMessage ?? 'Failed to load shop details',
        onRetry: () {
          ref.read(shopDetailsNotifierProvider(shopId).notifier)
              .loadShopDetails();
        },
      );
    }

    // ── Loaded State (shop is guaranteed non-null from here) ───────
    final shop = state.shop!;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(shopDetailsNotifierProvider(shopId).notifier)
            .loadShopDetails();
      },
      child: CustomScrollView(
        slivers: [
          // Shop header
          SliverToBoxAdapter(
            child: ShopHeaderSection(shop: shop),
          ),

          // "Our Menu" section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingM,
                AppDimens.paddingM,
                AppDimens.paddingM,
                0,
              ),
              child: Text(
                'Our Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Menu categories
          if (state.hasMenuItems && state.groupedMenuItems.isNotEmpty)
            SliverList(
              delegate: SliverChildListDelegate(
                state.groupedMenuItems.map(
                  (group) => MenuCategorySection(
                    group: group,
                    onItemAddTap: (item) {
                      context.push(
                        '/item-details',
                        extra: ItemDetailArgs(
                          item: item,
                          shopId: shopId,
                          shopName: shop.name,
                        ),
                      );
                    },
                  ),
                ).toList(),
              ),
            )

          // Empty menu state
          else if (!state.isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyMenuState(),
            ),

          // Bottom padding (accounts for ViewCartBanner overlay)
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimens.cartBannerBottomPadding),
          ),
        ],
      ),
    );
  }
}

/// Shown when the shop has no menu items.
class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              'Menu coming soon',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              'This shop hasn\'t added their menu yet.\nCheck back later!',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
