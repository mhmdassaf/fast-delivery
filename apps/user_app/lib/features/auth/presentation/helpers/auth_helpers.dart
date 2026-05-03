import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_providers.dart';

/// Helper function to handle Google Sign-In
/// Returns true if the operation is complete (not necessarily successful)
Future<void> handleGoogleSignIn(WidgetRef ref, Function(bool) setLoading) async {
  setLoading(true);
  try {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  } finally {
    setLoading(false);
  }
}
