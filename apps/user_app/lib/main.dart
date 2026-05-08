import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';
import 'package:fast_delivery_core/firebase/firebase_options.dart';
import 'package:fast_delivery_core/theme/app_theme.dart';
import 'package:fast_delivery_auth/presentation/screens/login_screen.dart';
import 'package:fast_delivery_auth/presentation/screens/register_screen.dart';
import 'package:fast_delivery_auth/presentation/screens/auth_gate.dart';

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
class FastDeliveryApp extends StatelessWidget {
  const FastDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fast Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}

/// GoRouter configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Main route - AuthGate handles auth state routing
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    // Explicit auth routes for navigation
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
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