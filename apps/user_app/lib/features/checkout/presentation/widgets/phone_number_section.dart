import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../domain/providers/checkout_providers.dart';

/// Displays a phone number input field with a fixed Lebanon (+961) country
/// code prefix. The phone number is saved to [CheckoutNotifier.setPhoneNumber]
/// on every change and validated as mandatory before placing the order.
class PhoneNumberSection extends ConsumerStatefulWidget {
  const PhoneNumberSection({super.key});

  @override
  ConsumerState<PhoneNumberSection> createState() => _PhoneNumberSectionState();
}

class _PhoneNumberSectionState extends ConsumerState<PhoneNumberSection> {
  final _controller = TextEditingController();
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with any existing value from the notifier (sync read)
    final existing = ref.read(checkoutNotifierProvider).phoneNumber;
    if (existing.isNotEmpty) {
      _controller.text = existing;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (!_hasInteracted) _hasInteracted = true;

    // Strip any non-digit characters
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits != value) {
      _controller.text = digits;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: digits.length),
      );
    }

    ref.read(checkoutNotifierProvider.notifier).setPhoneNumber(digits);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final phoneNumber = ref.watch(
      checkoutNotifierProvider.select((s) => s.phoneNumber),
    );
    final showError = _hasInteracted && phoneNumber.trim().isEmpty;

    // Listen for async phone pre-fill (e.g. after _loadInitialPhone()
    // fetches the user's phone from Firestore). Only pre-fill if the user
    // hasn't typed anything yet.
    ref.listen(
      checkoutNotifierProvider.select((s) => s.phoneNumber),
      (previous, next) {
        if (previous != next &&
            !_hasInteracted &&
            next.isNotEmpty &&
            _controller.text != next) {
          _controller.text = next;
        }
      },
    );

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(
          color: showError
              ? AppColors.error
              : AppColors.surfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: AppColors.secondary,
                size: AppDimens.iconM,
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Text(
                    'Phone Number',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Input row: country code badge + text field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Fixed country code badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppDimens.radiusS),
                          border: Border.all(
                            color: AppColors.surfaceVariant,
                          ),
                        ),
                        child: Text(
                          kLebanonCountryCode,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Phone number input
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: _onChanged,
                          keyboardType: TextInputType.phone,
                          maxLength: 8,
                          buildCounter: (
                            BuildContext context, {
                            required int currentLength,
                            required bool isFocused,
                            required int? maxLength,
                          }) =>
                              null, // Hide counter
                          decoration: InputDecoration(
                            hintText: '3 123 456',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            // Error text rendered separately below — not here
                            errorText: null,
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Error message (dedicated row — prevents overflow)
                  if (showError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Phone number is required',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
