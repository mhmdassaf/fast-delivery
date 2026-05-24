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

import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'features/shop_details/presentation/pages/shop_details_screen.dart';
import 'features/cart/presentation/pages/item_details_screen.dart';
import 'features/cart/presentation/pages/my_cart_screen.dart';
import 'features/cart/presentation/widgets/view_cart_banner.dart';
import 'features/checkout/presentation/pages/checkout_screen.dart';
import 'package:fast_delivery_orders/presentation/pages/orders_list_screen.dart';

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
      child: FastDeliveryApp(),
    ),
  );
}

/// Main application widget
class FastDeliveryApp extends ConsumerWidget {
  const FastDeliveryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Fast Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}

/// Provider-based GoRouter with authentication redirect.
///
/// Watches auth status and redirects accordingly:
/// - Unauthenticated users → /login
/// - Authenticated users on auth pages → /
/// - Authenticated users → free navigation
final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authStatus == AuthStatus.authenticated;
      final isAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isAuthPage && authStatus != AuthStatus.initial) {
        return '/login';
      }

      // Redirect authenticated users away from auth pages
      if (isAuthenticated && isAuthPage) {
        return '/';
      }

      return null;
    },
    routes: [
      // ── Auth routes (outside ShellRoute — no cart banner) ──────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── App routes (inside ShellRoute — includes ViewCartBanner) ───
      ShellRoute(
        builder: (context, state, child) => Stack(
          children: [
            child,
            const Align(
              alignment: Alignment.bottomCenter,
              child: ViewCartBanner(),
            ),
          ],
        ),
        routes: [
          // Main dashboard
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Shop details
          GoRoute(
            path: '/shop/:shopId',
            builder: (context, state) {
              final shopId = state.pathParameters['shopId'] ?? '';
              return ShopDetailsScreen(shopId: shopId);
            },
          ),

          // Item details (receives ItemDetailArgs via state.extra)
          GoRoute(
            path: '/item-details',
            builder: (context, state) => const ItemDetailsScreen(),
          ),
        ],
      ),

      // My cart (outside ShellRoute — no ViewCartBanner overlay)
      GoRoute(
        path: '/my-cart',
        builder: (context, state) => const MyCartScreen(),
      ),

      // Checkout (outside ShellRoute — no ViewCartBanner overlay)
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // My Orders
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


