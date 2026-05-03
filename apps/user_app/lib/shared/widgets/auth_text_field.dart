import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

/// A reusable text field for authentication screens
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final int? maxLength;
  final String? initialValue;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.focusNode,
    this.maxLength,
    this.initialValue,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textSecondary)
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                  semanticLabel: _obscureText
                      ? 'Show password'
                      : 'Hide password',
                ),
                onPressed: _toggleObscure,
              )
            : widget.suffixIcon,
        counterText: '',
      ),
    );
  }
}

/// Password text field with visibility toggle
class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      labelText: labelText,
      prefixIcon: Icons.lock_outlined,
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      autocorrect: false,
      enableSuggestions: false,
    );
  }
}