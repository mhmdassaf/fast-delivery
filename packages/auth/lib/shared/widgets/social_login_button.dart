import 'package:flutter/material.dart';
import 'package:fast_delivery_core/constants/app_constants.dart';

/// Social login button for Google and Apple
class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = provider == SocialProvider.google;
    final backgroundColor = isGoogle ? AppColors.surface : AppColors.appleBlack;
    final foregroundColor = isGoogle ? AppColors.onSurface : AppColors.onPrimary;
    final borderColor = isGoogle ? AppColors.surfaceVariant : Colors.transparent;
    final iconWidget = isGoogle 
        ? const Icon(Icons.g_mobiledata, size: 24)  // Use Material icon as placeholder
        : const Icon(Icons.apple, size: 20);

    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusL),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : iconWidget,
        label: Text(
          isGoogle ? 'Continue with Google' : 'Continue with Apple',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // For production, use actual brand assets:
  // Google: Use flutter_svg package with Google's official SVG
  // Apple: Use flutter_svg package with Apple's official logo
}

/// Social login provider types
enum SocialProvider {
  google,
  apple,
}
