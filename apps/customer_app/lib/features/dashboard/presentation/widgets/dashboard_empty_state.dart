import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Empty state widget displayed when there are no shops to show.
///
/// Shows different messages based on whether a search or filter is active.
class DashboardEmptyState extends StatelessWidget {
  final bool isSearchResults;
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;
  final VoidCallback? onClearSearch;

  const DashboardEmptyState({
    super.key,
    this.isSearchResults = false,
    this.hasActiveFilters = false,
    this.onClearFilters,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearchResults ? Icons.search_off_rounded : Icons.storefront_rounded,
              size: 80,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimens.paddingL),
            Text(
              isSearchResults ? 'No shops found' : 'No shops available',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              isSearchResults
                  ? 'Try adjusting your search or filters\nto find what you\'re looking for'
                  : 'There are no shops available in this\ncategory right now',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingL),
            if (isSearchResults && onClearSearch != null)
              TextButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(Icons.close),
                label: const Text('Clear search'),
              ),
            if (hasActiveFilters && onClearFilters != null)
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_list_off_rounded),
                label: const Text('Clear filters'),
              ),
          ],
        ),
      ),
    );
  }
}
