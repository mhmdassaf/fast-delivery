import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/auth_providers.dart';

/// Helper function to handle Google Sign-In loading state.
///
/// [role] is passed to the notifier so new user documents are created with
/// the correct role matching the app (customer, rider, seller, admin).
/// Calls [setLoading] with true before the sign-in attempt and false after completion.
Future<void> handleGoogleSignIn(
  WidgetRef ref,
  void Function(bool) setLoading, {
  UserRole role = UserRole.customer,
}) async {
  setLoading(true);
  try {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle(role: role);
  } finally {
    setLoading(false);
  }
}
