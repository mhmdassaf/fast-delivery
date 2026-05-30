import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/shop_filter_model.dart';

/// Modal bottom sheet for filtering shops.
///
/// Allows filtering by:
/// - Minimum rating
/// - Maximum delivery fee
/// - Open now toggle
/// - Sort option
class FilterBottomSheet extends StatefulWidget {
  final ShopFilterModel currentFilter;
  final ValueChanged<ShopFilterModel> onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  /// Show the filter bottom sheet
  static Future<void> show({
    required BuildContext context,
    required ShopFilterModel currentFilter,
    required ValueChanged<ShopFilterModel> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXL),
        ),
      ),
      builder: (context) => FilterBottomSheet(
        currentFilter: currentFilter,
        onApply: onApply,
      ),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ShopFilterModel _filter;
  late double _ratingValue;
  late double _deliveryFeeValue;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _ratingValue = widget.currentFilter.minRating ?? 0;
    _deliveryFeeValue = widget.currentFilter.maxDeliveryFee ?? 10;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimens.paddingL,
        right: AppDimens.paddingL,
        top: AppDimens.paddingL,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.paddingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Title
          Text(
            'Filters',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Sort Option
          Text('Sort by', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimens.paddingS),
          _SortSelector(
            current: _filter.sortBy,
            onChanged: (sort) => setState(() => _filter = _filter.copyWith(sortBy: sort)),
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Open Now Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Open now'),
            subtitle: const Text('Show only shops that are currently open'),
            value: _filter.openNow,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            onChanged: (value) => setState(() => _filter = _filter.copyWith(openNow: value)),
          ),
          const SizedBox(height: AppDimens.paddingS),

          // Rating Filter
          Text('Minimum rating', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimens.paddingS),
          _RatingSlider(
            value: _ratingValue,
            onChanged: (value) {
              setState(() {
                _ratingValue = value;
                _filter = _filter.copyWith(
                  minRating: value > 0 ? value : null,
                );
              });
            },
          ),
          const SizedBox(height: AppDimens.paddingL),

          // Delivery Fee Filter
          Text('Maximum delivery fee', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppDimens.paddingS),
          _DeliveryFeeSlider(
            value: _deliveryFeeValue,
            onChanged: (value) {
              setState(() {
                _deliveryFeeValue = value;
                _filter = _filter.copyWith(
                  maxDeliveryFee: value < 10 ? value : null,
                );
              });
            },
          ),
          const SizedBox(height: AppDimens.paddingXL),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    final reset = const ShopFilterModel();
                    widget.onApply(reset);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: AppDimens.paddingM),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_filter);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sort selector chips
class _SortSelector extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onChanged;

  const _SortSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.paddingS,
      runSpacing: AppDimens.paddingS,
      children: SortOption.values.map((option) {
        final isSelected = option == current;
        return ChoiceChip(
          label: Text(_sortLabel(option)),
          selected: isSelected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.onPrimary : AppColors.onBackground,
            fontSize: 13,
          ),
          onSelected: (_) => onChanged(option),
        );
      }).toList(),
    );
  }

  String _sortLabel(SortOption option) {
    switch (option) {
      case SortOption.rating:
        return 'Rating';
      case SortOption.deliveryFee:
        return 'Delivery Fee';
      case SortOption.distance:
        return 'Distance';
      case SortOption.newest:
        return 'Newest';
    }
  }
}

/// Rating slider
class _RatingSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _RatingSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceVariant,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 5,
              divisions: 10,
              label: value > 0 ? '${value.toStringAsFixed(1)}+' : 'Any',
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value > 0 ? '${value.toStringAsFixed(1)}+' : 'Any',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Delivery fee slider
class _DeliveryFeeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _DeliveryFeeSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              thumbColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceVariant,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 10,
              divisions: 20,
              label: value < 10 ? '\$${value.toStringAsFixed(1)}' : 'Any',
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value < 10 ? '\$${value.toStringAsFixed(1)}' : 'Any',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
