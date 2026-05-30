import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/firebase/firebase_options.dart';
import 'package:fast_delivery_core/theme/app_theme.dart';
import 'package:fast_delivery_core/widgets/main_shell.dart';
import 'package:fast_delivery_core/widgets/not_found_page.dart';
import 'package:fast_delivery_auth/domain/providers/auth_providers.dart';
import 'package:fast_delivery_auth/presentation/screens/login_screen.dart';
import 'package:fast_delivery_auth/presentation/screens/register_screen.dart';
import 'package:fast_delivery_orders/presentation/pages/orders_list_screen.dart';

import 'presentation/pages/admin_dashboard_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: AdminPanelApp(),
    ),
  );
}

/// Main application widget for Admin Panel
class AdminPanelApp extends ConsumerWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fast Delivery - Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}

/// Provider-based GoRouter with authentication redirect.
final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authStatus == AuthStatus.authenticated;
      final isAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthPage && authStatus != AuthStatus.initial) {
        return '/login';
      }

      if (isAuthenticated && isAuthPage) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main shell with bottom navigation (Home / Orders / Account)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          navigationShell: navigationShell,
        ),
        branches: [
          // Home tab — Admin Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),

          // Orders tab — shared OrdersListScreen
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersListScreen(),
              ),
            ],
          ),

          // Account tab — placeholder (no-op for future use)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundPage(state: state),
  );
});
