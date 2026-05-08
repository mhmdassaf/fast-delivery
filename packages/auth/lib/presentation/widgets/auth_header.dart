import 'package:flutter/material.dart';
import 'package:fast_delivery_core/constants/app_constants.dart';

/// Header widget for authentication screens
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? logoPath;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoPath,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBackButton)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.paddingM),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                iconSize: 28,
                style: IconButton.styleFrom(
                  minimumSize: const Size(AppDimens.minTouchTarget, AppDimens.minTouchTarget),
                ),
              ),
            ),
          ),
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fastfood_outlined,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppDimens.paddingL),
        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.paddingS),
        // Subtitle
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}