import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';
import 'package:fast_delivery_core/utils/validators.dart';
import 'package:fast_delivery_auth/shared/widgets/auth_text_field.dart';
import 'package:fast_delivery_auth/shared/widgets/primary_button.dart';
import 'package:fast_delivery_auth/shared/widgets/loading_overlay.dart';
import 'package:fast_delivery_auth/shared/widgets/social_login_button.dart';
import 'package:fast_delivery_auth/shared/widgets/auth_error_message.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/auth_providers.dart';
import '../widgets/auth_header.dart';
import '../helpers/auth_helpers.dart';

/// Login screen for user authentication
///
/// [initialRole] is used when creating a new user document via Google Sign-In.
/// Each app passes its own role so that new Google users get the correct role.
class LoginScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const LoginScreen({
    super.key,
    this.initialRole = UserRole.customer,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    ref.read(authNotifierProvider.notifier).clearError();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      // Navigation will be handled by AuthGate
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await handleGoogleSignIn(
      ref,
      (loading) => setState(() => _isGoogleLoading = loading),
      role: widget.initialRole,
    );
  }

  void _handleForgotPassword() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address first'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send password reset link to $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref
                  .read(authNotifierProvider.notifier)
                  .sendPasswordResetEmail(email: email);

              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset link sent to $email'
                          : 'Failed to send reset link',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingL,
              vertical: AppDimens.paddingXL,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimens.paddingXXL),
                  const AuthHeader(
                    title: 'Welcome Back!',
                    subtitle: 'Sign in to continue ordering your favorite food',
                  ),
                  const SizedBox(height: AppDimens.paddingXXL),
                  AuthErrorMessage(errorMessage: authState.errorMessage),
                  AuthTextField(
                    controller: _emailController,
                    labelText: 'Email address',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocusNode,
                    validator: Validators.email,
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    focusNode: _passwordFocusNode,
                    validator: Validators.password,
                    onSubmitted: (_) => _handleSignIn(),
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  PrimaryButton(
                    text: 'SIGN IN',
                    onPressed: _handleSignIn,
                    isLoading: authState.isLoading,
                    icon: Icons.login,
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingM,
                        ),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  SocialLoginButton(
                    provider: SocialProvider.google,
                    onPressed: _handleGoogleSignIn,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: AppDimens.paddingXXL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(AppDimens.minTouchTarget, AppDimens.minTouchTarget),
                        ),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}