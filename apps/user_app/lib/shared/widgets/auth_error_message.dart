import 'package:flutter/material.dart';

/// Reusable error message widget for authentication screens
class AuthErrorMessage extends StatelessWidget {
  final String? errorMessage;
  
  const AuthErrorMessage({super.key, this.errorMessage});
  
  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();
    
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
