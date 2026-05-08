import 'package:flutter/material.dart';
import 'package:fast_delivery_core/constants/app_constants.dart';

/// Reusable error message widget for authentication screens
class AuthErrorMessage extends StatelessWidget {
  final String? errorMessage;

  const AuthErrorMessage({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingS),
      margin: const EdgeInsets.only(bottom: AppDimens.paddingM),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: AppDimens.iconM,
          ),
          const SizedBox(width: AppDimens.paddingS),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
