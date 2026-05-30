import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/cart_item_model.dart';
import '../../domain/providers/cart_providers.dart';
import '../widgets/quantity_selector.dart';

/// Displays the user's shopping cart contents with quantity controls and a
/// clear all action. The bottom bar provides [Add Items] to continue shopping
/// and [Checkout] with the total amount displayed inside the button.
class MyCartScreen extends ConsumerWidget {
  const MyCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);
    final shopId = ref.read(cartShopIdProvider);
    final goToShop = shopId != null ? () => context.go('/shop/$shopId') : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: () => _showClearDialog(context, ref),
              icon: const Icon(Icons.delete_sweep_rounded),
              tooltip: 'Clear all items',
            ),
        ],
      ),
      body: cart.isEmpty
          ? _EmptyCart(onBrowseShops: () => context.go('/'))
          : _CartContent(
              cart: cart,
              total: total,
              onAddItems: goToShop,
              onCheckout: () => context.push('/checkout'),
              onRemoveItem: (id) =>
                  ref.read(cartNotifierProvider.notifier).removeItem(id),
              onUpdateQuantity: (id, quantity) =>
                  ref.read(cartNotifierProvider.notifier)
                      .updateQuantity(id, quantity),
            ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text(
          'This will remove all items from your cart.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Empty Cart State
// ============================================================================

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowseShops;

  const _EmptyCart({required this.onBrowseShops});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: AppColors.textHint.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppDimens.paddingL),
            Text(
              'Your cart is empty',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              'Browse shops to add delicious items to your cart!',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimens.paddingXL),
            SizedBox(
              width: double.infinity,
              height: AppDimens.buttonHeight,
              child: ElevatedButton(
                onPressed: onBrowseShops,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                  ),
                ),
                child: const Text(
                  'Browse Shops',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Cart Content (items + summary)
// ============================================================================

class _CartContent extends StatelessWidget {
  final List<CartItemModel> cart;
  final double total;
  final VoidCallback? onAddItems;
  final VoidCallback onCheckout;
  final void Function(String id) onRemoveItem;
  final void Function(String id, int quantity) onUpdateQuantity;

  const _CartContent({
    required this.cart,
    required this.total,
    this.onAddItems,
    required this.onCheckout,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scrollable items list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: AppDimens.paddingS,
              bottom: AppDimens.paddingM,
            ),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              return _CartItemCard(
                item: cart[index],
                onRemovePressed: onRemoveItem,
                onQuantityChanged: onUpdateQuantity,
              );
            },
          ),
        ),

        // Bottom action bar (Add Items + Checkout)
        _CartBottomBar(
          subtotal: total,
          onAddItems: onAddItems,
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}

// ============================================================================
// Cart Item Card
// ============================================================================

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final void Function(String id) onRemovePressed;
  final void Function(String id, int quantity) onQuantityChanged;

  const _CartItemCard({
    required this.item,
    required this.onRemovePressed,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: 4,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusL),
        side: BorderSide(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              child: SizedBox(
                width: 64,
                height: 64,
                child: _buildImage(),
              ),
            ),
            const SizedBox(width: AppDimens.paddingM),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + remove button row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => onRemovePressed(item.id),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.textHint,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove ${item.name}',
                      ),
                    ],
                  ),

                  // Special instructions
                  if (item.specialInstructions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '"${item.specialInstructions}"',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: AppDimens.paddingS),

                  // Price + quantity row
                  Row(
                    children: [
                      // Price
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),

                      // Quantity selector
                      QuantitySelector(
                        quantity: item.quantity,
                        min: 0,
                        onChanged: (qty) {
                          onQuantityChanged(item.id, qty);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.imageUrl == null || item.imageUrl!.isEmpty) {
      return Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.restaurant_rounded,
          size: 28,
          color: AppColors.textHint,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.imageUrl!,
      fit: BoxFit.cover,
      width: 64,
      height: 64,
      placeholder: (_, __) => Container(
        color: AppColors.surface,
      ),
      errorWidget: (_, __, ___) => Container(
        color: AppColors.surface,
        child: const Icon(
          Icons.restaurant_rounded,
          size: 28,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}

// ============================================================================
// Cart Bottom Action Bar
// ============================================================================

class _CartBottomBar extends StatelessWidget {
  final double subtotal;
  final VoidCallback? onAddItems;
  final VoidCallback onCheckout;

  const _CartBottomBar({
    required this.subtotal,
    this.onAddItems,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingM,
        AppDimens.paddingM,
        AppDimens.paddingM,
        AppDimens.paddingL,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bottom actions: Add Items + Checkout
            Row(
              children: [
                // Add Items button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: AppDimens.buttonHeight,
                    child: OutlinedButton(
                      onPressed: onAddItems ?? () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(
                          'Add Items',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),

                // Checkout button with total amount
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: AppDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Checkout \$${subtotal.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


