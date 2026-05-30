import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// A debounced search bar widget for searching shops.
///
/// Features:
/// - Real-time search with debounce
/// - Clear button when text is entered
/// - Empty state support
/// - Customizable hint text
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Search shops, categories...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.onBackground,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
          size: AppDimens.iconM,
        ),
        suffixIcon: _SearchClearButton(
          controller: controller,
          onClear: onClear,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingM,
          vertical: AppDimens.paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusL),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

/// Clear button that appears when the search field has text
class _SearchClearButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchClearButton({
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return IconButton(
          onPressed: () {
            controller.clear();
            onClear();
          },
          icon: const Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
            size: AppDimens.iconM,
          ),
          splashRadius: AppDimens.minTouchTarget / 2,
        );
      },
    );
  }
}
