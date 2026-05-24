import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';
import 'package:fast_delivery_core/firebase/firebase_options.dart';
import 'package:fast_delivery_core/theme/app_theme.dart';
import 'package:fast_delivery_auth/domain/providers/auth_providers.dart';
import 'package:fast_delivery_auth/presentation/screens/login_screen.dart';
import 'package:fast_delivery_auth/presentation/screens/register_screen.dart';
import 'package:fast_delivery_orders/presentation/pages/orders_list_screen.dart';

import 'presentation/pages/seller_dashboard_screen.dart';

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
      child: SellerApp(),
    ),
  );
}

/// Main application widget for Seller App
class SellerApp extends ConsumerWidget {
  const SellerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fast Delivery - Seller',
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
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // App routes
      GoRoute(
        path: '/',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersListScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
