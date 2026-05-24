import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';
import 'package:fast_delivery_auth/domain/providers/auth_providers.dart';

/// Admin dashboard screen — simple landing with role title and navigation.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXL),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingL),

                // Title
                Text(
                  'Admin Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackground,
                      ),
                ),
                const SizedBox(height: AppDimens.paddingS),

                // User name
                Text(
                  user?.displayName ?? 'Welcome, Admin!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingXL),

                // View Orders button
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/orders'),
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('All Orders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingL),

                // Sign Out button
                TextButton(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
