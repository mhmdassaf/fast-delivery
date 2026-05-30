import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../domain/providers/cart_providers.dart';

/// A fixed-position banner at the bottom of the screen showing cart summary.
///
/// Appears with a slide-up animation when items are added to the cart and
/// disappears when the cart is empty. Tapping [View Cart] navigates to
/// `/my-cart`.
///
/// This widget is intended to be placed inside a `Stack` at the scaffold level
/// (via the ShellRoute builder) so it is visible from any app screen.
class ViewCartBanner extends ConsumerStatefulWidget {
  const ViewCartBanner({super.key});

  @override
  ConsumerState<ViewCartBanner> createState() => _ViewCartBannerState();
}

class _ViewCartBannerState extends ConsumerState<ViewCartBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  bool _hasItems = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = ref.watch(hasCartItemsProvider);
    final count = ref.watch(cartItemCountProvider);
    final total = ref.watch(cartTotalProvider);
    final textTheme = Theme.of(context).textTheme;

    // Only animate when the state actually changes (avoids side-effects in
    // build(), since build() can be called multiple times per frame).
    if (hasItems != _hasItems) {
      _hasItems = hasItems;
      if (hasItems) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    return SlideTransition(
      position: _slideAnimation,
      child: hasItems
          ? Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingM,
                AppDimens.paddingS,
                AppDimens.paddingS,
                AppDimens.paddingL,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Cart icon + item count
                    const Icon(
                      Icons.shopping_cart_rounded,
                      color: AppColors.onPrimary,
                      size: AppDimens.iconM,
                    ),
                    const SizedBox(width: AppDimens.paddingS),
                    Text(
                      '$count ${count == 1 ? 'item' : 'items'}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: AppDimens.paddingXS),

                    // Total price
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // View Cart button
                    TextButton.icon(
                      onPressed: () => context.push('/my-cart'),
                      icon: const Icon(
                        Icons.visibility_rounded,
                        color: AppColors.onPrimary,
                        size: 20,
                      ),
                      label: Text(
                        'View Cart',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingM,
                          vertical: AppDimens.paddingS,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusRound),
                          side: const BorderSide(
                            color: AppColors.onPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
