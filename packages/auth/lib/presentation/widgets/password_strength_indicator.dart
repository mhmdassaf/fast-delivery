import 'package:flutter/material.dart';
import 'package:fast_delivery_core/constants/app_constants.dart';
import 'package:fast_delivery_core/utils/validators.dart';

// Import PasswordStrength and calculatePasswordStrength from validators
// They are defined in the core package

/// Password strength indicator widget
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showRequirements;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showRequirements = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = calculatePasswordStrength(password);
    final isEmpty = password.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        Row(
          children: [
            _buildBar(
              context,
              isActive: !isEmpty && strength.index >= PasswordStrength.weak.index,
              color: _getBarColor(strength, PasswordStrength.weak),
            ),
            const SizedBox(width: 4),
            _buildBar(
              context,
              isActive: strength.index >= PasswordStrength.medium.index,
              color: _getBarColor(strength, PasswordStrength.medium),
            ),
            const SizedBox(width: 4),
            _buildBar(
              context,
              isActive: strength.index >= PasswordStrength.strong.index,
              color: _getBarColor(strength, PasswordStrength.strong),
            ),
          ],
        ),
        if (showRequirements && !isEmpty) ...[
          const SizedBox(height: AppDimens.paddingS),
          // Requirements text
          Text(
            _getStrengthText(strength),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _getBarColor(strength, strength),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildBar(
    BuildContext context, {
    required bool isActive,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: isActive ? color : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Color _getBarColor(PasswordStrength currentStrength, PasswordStrength barStrength) {
    if (currentStrength.index < barStrength.index) {
      return AppColors.surfaceVariant;
    }

    switch (currentStrength) {
      case PasswordStrength.weak:
        return AppColors.error;
      case PasswordStrength.medium:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.success;
      case PasswordStrength.empty:
        return AppColors.surfaceVariant;
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak password. Add more characters, numbers, and symbols.';
      case PasswordStrength.medium:
        return 'Medium password. Try adding more special characters.';
      case PasswordStrength.strong:
        return 'Strong password!';
      case PasswordStrength.empty:
        return '';
    }
  }
}