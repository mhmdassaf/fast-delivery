import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_auth/domain/providers/auth_providers.dart';
import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/shop_filter_model.dart';
import '../../domain/providers/dashboard_providers.dart';
import '../widgets/categories_bar.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_empty_state.dart';
import '../widgets/dashboard_error_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/shop_list.dart';

/// Main dashboard screen for the user app.
///
/// Composes all dashboard widgets into a single scrollable page.
/// Handles initial loading, pull-to-refresh, pagination, and error states.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load initial data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dashboardNotifierProvider.notifier).loadInitialData();
      }
    });
    // Note: Pagination is handled by ShopList's NotificationListener
    // via the onLoadMore callback — no duplicate listener needed here.
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(dashboardNotifierProvider.notifier).refresh(),
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ==============================================================
              // App Bar Section
              // ==============================================================
              SliverToBoxAdapter(
                child: DashboardAppBar(
                  userName: user?.displayName,
                  userPhotoUrl: user?.photoURL,
                  location: 'Deliver to: Home',
                  onNotificationTap: () {
                    // Future: Navigate to notifications
                  },
                  onLocationTap: () {
                    // Future: Open location picker
                  },
                ),
              ),

              // ==============================================================
              // Search Bar Section + My Orders
              // ==============================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingM,
                    AppDimens.paddingS,
                    AppDimens.paddingM,
                    AppDimens.paddingS,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SearchBarWidget(
                          controller: _searchController,
                          onChanged: (query) {
                            ref
                                .read(dashboardNotifierProvider.notifier)
                                .onSearchChanged(query);
                          },
                          onClear: () {
                            ref
                                .read(dashboardNotifierProvider.notifier)
                                .clearSearch();
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingS),
                      // My Orders button
                      Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusL),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppDimens.radiusL),
                          onTap: () => context.push('/orders'),
                          child: Container(
                            width: AppDimens.buttonHeight,
                            height: AppDimens.buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.radiusL),
                              border: Border.all(
                                color: AppColors.surfaceVariant,
                              ),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingS),
                      // Filter button
                      Material(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusL),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppDimens.radiusL),
                          onTap: () => _showFilterSheet(state),
                          child: Container(
                            width: AppDimens.buttonHeight,
                            height: AppDimens.buttonHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppDimens.radiusL),
                              border: Border.all(
                                color: state.hasActiveFilters
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: state.hasActiveFilters
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==============================================================
              // Categories Section
              // ==============================================================
              SliverToBoxAdapter(
                child: CategoriesBar(
                  categories: state.categories,
                  selectedCategoryId: state.selectedCategoryId,
                  onCategorySelected: (categoryId) {
                    ref
                        .read(dashboardNotifierProvider.notifier)
                        .selectCategory(categoryId);
                  },
                  isLoading: state.isLoading && state.categories.isEmpty,
                ),
              ),

              // ==============================================================
              // Active Filter Indicators
              // ==============================================================
              if (state.hasActiveFilters)
                SliverToBoxAdapter(
                  child: _ActiveFilterChips(
                    filter: state.filter,
                    onClearFilters: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .clearFilters(),
                    onToggleOpenNow: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .toggleOpenNow(),
                    onRemoveRating: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .removeRatingFilter(),
                    onRemoveDeliveryFee: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .removeDeliveryFeeFilter(),
                  ),
                ),

              // ==============================================================
              // Section Header
              // ==============================================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingM,
                    AppDimens.paddingM,
                    AppDimens.paddingM,
                    AppDimens.paddingS,
                  ),
                  child: Row(
                    children: [
                      Text(
                        state.selectedCategory?.name ?? 'All Shops',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (state.hasShops)
                        Text(
                          '${state.shops.length} shops',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ==============================================================
              // Shop Listing / Empty / Error
              // ==============================================================
              if (state.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DashboardErrorState(
                    message: state.errorMessage!,
                    onRetry: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .loadInitialData(),
                  ),
                )
              else if (!state.isLoading && !state.hasShops)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: DashboardEmptyState(
                    isSearchResults: state.searchQuery.isNotEmpty,
                    hasActiveFilters: state.hasActiveFilters,
                    onClearSearch: () {
                      _searchController.clear();
                      ref
                          .read(dashboardNotifierProvider.notifier)
                          .clearSearch();
                    },
                    onClearFilters: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .clearFilters(),
                  ),
                )
              else
                // ShopList uses ListView.builder with shrinkWrap: true +
                // NeverScrollableScrollPhysics(), so it sizes naturally within the sliver.
                SliverToBoxAdapter(
                  child: ShopList(
                    shops: state.shops,
                    isLoading: state.isLoading,
                    isLoadingMore: state.isLoadingMore,
                    hasMoreData: state.hasMoreData,
                    onLoadMore: () => ref
                        .read(dashboardNotifierProvider.notifier)
                        .loadMoreShops(),
                  ),
                ),

              // ==============================================================
              // Loading More Indicator
              if (state.isLoadingMore && !state.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppDimens.paddingM),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

              // Bottom padding (accounts for ViewCartBanner overlay)
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.cartBannerBottomPadding),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterSheet(DashboardState state) {
    FilterBottomSheet.show(
      context: context,
      currentFilter: state.filter,
      onApply: (filter) {
        ref.read(dashboardNotifierProvider.notifier).updateFilter(filter);
      },
    );
  }
}

/// Active filter chips displayed below the category bar
class _ActiveFilterChips extends StatelessWidget {
  final ShopFilterModel filter;
  final VoidCallback onClearFilters;
  final VoidCallback onToggleOpenNow;
  final VoidCallback? onRemoveRating;
  final VoidCallback? onRemoveDeliveryFee;

  const _ActiveFilterChips({
    required this.filter,
    required this.onClearFilters,
    required this.onToggleOpenNow,
    this.onRemoveRating,
    this.onRemoveDeliveryFee,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingM,
        AppDimens.paddingS,
        AppDimens.paddingM,
        0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Open Now chip
            if (filter.openNow)
              _FilterChip(
                label: 'Open Now',
                icon: Icons.lock_open_rounded,
                onRemove: onToggleOpenNow,
              ),

            // Rating chip
            if (filter.minRating != null)
              _FilterChip(
                label: '${filter.minRating!.toStringAsFixed(1)}+ Rating',
                icon: Icons.star_rounded,
                onRemove: onRemoveRating ?? () {},
              ),

            // Delivery fee chip
            if (filter.maxDeliveryFee != null)
              _FilterChip(
                label: 'Max \$${filter.maxDeliveryFee!.toStringAsFixed(1)}',
                icon: Icons.motorcycle_rounded,
                onRemove: onRemoveDeliveryFee ?? () {},
              ),

            const SizedBox(width: AppDimens.paddingS),

            // Clear all button
            TextButton(
              onPressed: onClearFilters,
              child: const Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual filter chip with remove icon
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onRemove;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppDimens.paddingS),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimens.radiusRound),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
