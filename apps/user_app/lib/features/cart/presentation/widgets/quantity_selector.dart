import 'package:flutter/material.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

/// A compact horizontal quantity selector with [-] and [+] buttons.
///
/// Layout:
/// ```
/// [─] 2 [+]
/// ```
///
/// The minimum value is [min] (default 1). Provide [max] for an upper bound
/// (null means no upper bound).
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max,
  });

  bool get _canDecrement => quantity > min;
  bool get _canIncrement => max == null || quantity < max!;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement
        _CircleButton(
          icon: Icons.remove_rounded,
          onPressed: _canDecrement ? () => onChanged(quantity - 1) : null,
        ),
        const SizedBox(width: AppDimens.paddingS),

        // Quantity
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppDimens.paddingS),

        // Increment
        _CircleButton(
          icon: Icons.add_rounded,
          onPressed: _canIncrement ? () => onChanged(quantity + 1) : null,
        ),
      ],
    );
  }
}

/// A circular icon button used as a quantity control.
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircleButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEnabled
            ? AppColors.surfaceVariant
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
      ),
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: isEnabled ? AppColors.onSurface : AppColors.textHint,
        ),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        tooltip: isEnabled
            ? (icon == Icons.add_rounded ? 'Increase' : 'Decrease')
            : null,
      ),
    );
  }
}
