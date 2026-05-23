import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/delivery_address_model.dart';

/// Displays the selected delivery address with a [Change] button that
/// opens a bottom sheet for address selection (current location / manual).
class DeliveryAddressSection extends StatelessWidget {
  final DeliveryAddressModel? address;
  final VoidCallback onChangePressed;

  const DeliveryAddressSection({
    super.key,
    required this.address,
    required this.onChangePressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingXS,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
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
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: AppDimens.iconM,
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),
            // Address text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Delivery Address',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Change button
                      SizedBox(
                        height: 32,
                        child: TextButton(
                          onPressed: onChangePressed,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingS,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (address != null) ...[
                    Text(
                      address!.addressLine,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address!.label.isNotEmpty &&
                        address!.label != 'Current Location')
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Label: ${address!.label}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ] else
                    Text(
                      'No address set',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textHint,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

/// Represents the action chosen in the address options bottom sheet.
enum AddressAction { useDevice, setManual }

/// Shows a modal bottom sheet with address options.
Future<AddressAction?> showAddressOptionsSheet(BuildContext context) {
  return showModalBottomSheet<AddressAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusXL)),
    ),
    builder: (ctx) {
      final textTheme = Theme.of(ctx).textTheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingM,
            AppDimens.paddingL,
            AppDimens.paddingM,
            AppDimens.paddingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Set Delivery Address',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.paddingL),

              // Use current location
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(AddressAction.useDevice),
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Use Current Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.paddingM),

              // Enter manually
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(AddressAction.setManual),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Enter Manually'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
