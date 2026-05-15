import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// Custom app bar for the dashboard screen.
///
/// Displays:
/// - Greeting with user's name
/// - Current delivery location
/// - Notification bell icon
/// - Optional profile avatar
class DashboardAppBar extends StatelessWidget {
  final String? userName;
  final String? userPhotoUrl;
  final String location;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLocationTap;
  final int notificationCount;

  const DashboardAppBar({
    super.key,
    this.userName,
    this.userPhotoUrl,
    this.location = 'Current location',
    this.onNotificationTap,
    this.onLocationTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingS,
      ),
      child: Row(
        children: [
          // Greeting + Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _greeting,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onLocationTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: AppDimens.iconS,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: AppDimens.iconS,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          Stack(
            children: [
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.onBackground,
                ),
                splashRadius: AppDimens.minTouchTarget / 2,
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      notificationCount > 99 ? '99+' : '$notificationCount',
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Profile Avatar
          const SizedBox(width: AppDimens.paddingXS),
          GestureDetector(
            onTap: () {
              // Future: Navigate to profile
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: userPhotoUrl != null
                  ? NetworkImage(userPhotoUrl!)
                  : null,
              child: userPhotoUrl == null
                  ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.textSecondary,
                      size: AppDimens.iconM,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Generate greeting based on time of day
  String get _greeting {
    if (userName != null && userName!.isNotEmpty) {
      return 'Hello, $userName!';
    }

    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}
