import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_providers.dart';

/// Helper function to handle Google Sign-In loading state.
/// Calls [setLoading] with true before the sign-in attempt and false after completion.
Future<void> handleGoogleSignIn(WidgetRef ref, void Function(bool) setLoading) async {
  setLoading(true);
  try {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  } finally {
    setLoading(false);
  }
}
