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
import '../widgets/password_strength_indicator.dart';
import '../helpers/auth_helpers.dart';

/// Register screen for new user registration
///
/// [initialRole] determines the role assigned to the user's Firestore document
/// upon successful registration. Each app passes its own role:
/// - Customer App → [UserRole.customer] (default)
/// - Rider App → [UserRole.rider]
/// - Seller App → [UserRole.seller]
/// - Admin Panel → [UserRole.admin]
class RegisterScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const RegisterScreen({
    super.key,
    this.initialRole = UserRole.customer,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isGoogleLoading = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Clear previous errors
    ref.read(authNotifierProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
          role: widget.initialRole,
        );

    if (success && mounted) {
      // Navigation will be handled by AuthGate
    }
  }

  Future<void> _handleGoogleSignUp() async {
    await handleGoogleSignIn(
      ref,
      (loading) => setState(() => _isGoogleLoading = loading),
      role: widget.initialRole,
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
                  const SizedBox(height: AppDimens.paddingL),
                  // Back button and Header
                  AuthHeader(
                    title: 'Create Account',
                    subtitle: 'Join thousands of food lovers today!',
                    showBackButton: true,
                    onBackPressed: () => context.pop(),
                  ),
                  const SizedBox(height: AppDimens.paddingXXL),
                  // Error message
                  AuthErrorMessage(errorMessage: authState.errorMessage),
                  // Name field
                  AuthTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outlined,
                    textInputAction: TextInputAction.next,
                    focusNode: _nameFocusNode,
                    validator: Validators.name,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    labelText: 'Email address',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocusNode,
                    validator: Validators.email,
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: Icons.lock_outlined,
                    textInputAction: TextInputAction.next,
                    focusNode: _passwordFocusNode,
                    validator: Validators.strongPassword,
                    obscureText: true,
                    onChanged: (value) => setState(() {}),
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                  // Password strength indicator
                  PasswordStrengthIndicator(password: _passwordController.text),
                  const SizedBox(height: AppDimens.paddingM),
                  // Confirm Password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icons.lock_outlined,
                    textInputAction: TextInputAction.done,
                    focusNode: _confirmPasswordFocusNode,
                    validator: (value) =>
                        Validators.confirmPassword(value, _passwordController.text),
                    obscureText: true,
                    onSubmitted: (_) => _handleSignUp(),
                    autocorrect: false,
                    enableSuggestions: false,
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  // Terms and conditions checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                        activeColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.textSecondary),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppDimens.paddingXS),
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  // Sign up button
                  PrimaryButton(
                    text: 'CREATE ACCOUNT',
                    onPressed: _handleSignUp,
                    isLoading: authState.isLoading,
                    icon: Icons.person_add,
                  ),
                  const SizedBox(height: AppDimens.paddingL),
                  // Divider
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
                  // Google sign up
                  SocialLoginButton(
                    provider: SocialProvider.google,
                    onPressed: _handleGoogleSignUp,
                    isLoading: _isGoogleLoading,
                  ),
                  const SizedBox(height: AppDimens.paddingXXL),
                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(AppDimens.minTouchTarget, AppDimens.minTouchTarget),
                        ),
                        child: const Text('Sign In'),
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
