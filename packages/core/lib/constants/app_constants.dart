import 'package:flutter/material.dart';

/// App color constants following the design guide
/// Primary: Orange (#FF6B35) - appetite stimulating
/// Secondary: Teal (#2EC4B6) - fresh, trustworthy
abstract final class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryVariant = Color(0xFFE85A24);
  static const Color primaryLight = Color(0xFFFF8F66);

  // Secondary Colors
  static const Color secondary = Color(0xFF2EC4B6);
  static const Color secondaryVariant = Color(0xFF259E92);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFE9ECEF);

  // Text Colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Semantic Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFA726);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFB0B0B0);

  // Social Button Colors
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color appleBlack = Color(0xFF000000);
}

/// App dimension constants
abstract final class AppDimens {
  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 100.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Button Heights
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;
  static const double textFieldHeight = 56.0;

  // Touch Target (WCAG 2.1 AA compliance)
  static const double minTouchTarget = 48.0;

  // ViewCartBanner bottom padding (ensures scrollable content is not hidden
  // behind the floating cart banner overlay)
  static const double cartBannerBottomPadding = 88.0;
}