import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/shop_model.dart';
import 'shop_card.dart';
import 'shop_card_skeleton.dart';

/// Paginated shop listing with infinite scrolling.
///
/// Features:
/// - Grid layout for optimal space usage
/// - Infinite scroll pagination
/// - Loading skeleton during pagination
/// - Tap to navigate to shop details
class ShopList extends StatelessWidget {
  final List<ShopModel> shops;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMoreData;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;

  const ShopList({
    super.key,
    required this.shops,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMoreData = true,
    this.scrollController,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    // Show skeletons during initial load
    if (isLoading) {
      return _buildSkeletonGrid();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Detect when user scrolls near the bottom
        if (notification is ScrollEndNotification &&
            hasMoreData &&
            !isLoadingMore &&
            onLoadMore != null) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            onLoadMore!();
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingM,
          0,
          AppDimens.paddingM,
          AppDimens.paddingXL,
        ),
        itemCount: shops.length + (isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          // Show loading skeleton at the end when loading more
          if (index >= shops.length) {
            return const Padding(
              padding: EdgeInsets.only(top: AppDimens.paddingS),
              child: ShopCardSkeleton(),
            );
          }

          final shop = shops[index];
          return Padding(
            padding: const EdgeInsets.only(top: AppDimens.paddingS),
            child: ShopCard(
              shop: shop,
              onTap: () => context.push('/shop/${shop.id}'),
            ),
          );
        },
      ),
    );
  }

  /// Build skeleton list for initial loading
  Widget _buildSkeletonGrid() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingM,
        0,
        AppDimens.paddingM,
        AppDimens.paddingXL,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(top: AppDimens.paddingS),
        child: ShopCardSkeleton(),
      ),
    );
  }
}
