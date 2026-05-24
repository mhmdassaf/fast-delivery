import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../domain/order_list_providers.dart';
import '../widgets/order_card.dart';
import '../widgets/order_list_empty_state.dart';
import '../widgets/order_list_loading.dart';
import '../widgets/order_status_filter_bar.dart';

/// Main orders list screen.
///
/// Shows a scrollable list of orders with pull-to-refresh, pagination,
/// and status filter chips at the top.
class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listen for scroll near the bottom to trigger pagination.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(orderListNotifierProvider.notifier).loadMoreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderListNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status filter bar
            OrderStatusFilterBar(
              selectedFilter: state.selectedStatusFilter,
              onFilterSelected: (filter) {
                ref
                    .read(orderListNotifierProvider.notifier)
                    .setStatusFilter(filter);
              },
            ),
            const SizedBox(height: AppDimens.paddingXS),

            // Orders list / loading / empty / error
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OrderListState state) {
    // Initial loading state
    if (state.isLoading && !state.hasOrders) {
      return const OrderListLoading();
    }

    // Error state with no data
    if (state.hasError && !state.hasOrders) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimens.paddingM),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimens.paddingL),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(orderListNotifierProvider.notifier)
                      .loadInitialData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (!state.isLoading && !state.hasOrders) {
      return OrderListEmptyState(
        hasActiveFilter: state.selectedStatusFilter != null,
      );
    }

    // Data list
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(orderListNotifierProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppDimens.paddingXL),
        itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.orders.length) {
            // Pagination loading indicator
            return const Padding(
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
            );
          }

          final order = state.orders[index];
          return OrderCard(
            order: order,
            onTap: () {
              // Future: Navigate to order details screen
            },
          );
        },
      ),
    );
  }
}
