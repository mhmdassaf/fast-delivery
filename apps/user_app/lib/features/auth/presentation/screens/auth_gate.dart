import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/loading_overlay.dart';
import '../../domain/providers/auth_providers.dart';
import 'login_screen.dart';

/// Authentication gate - routes to login/register or home based on auth state
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authStatusProvider);

    if (authStatus == AuthStatus.initial) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Checking authentication...'),
      );
    }

    if (authStatus == AuthStatus.authenticated) {
      // User is authenticated - navigate to home
      // This will be replaced with actual home screen
      return _HomePlaceholder();
    }

    // User is not authenticated - show login
    return LoginScreen();
  }
}

/// Placeholder for home screen (to be replaced with actual home implementation)
class _HomePlaceholder extends ConsumerWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You are now logged in',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}