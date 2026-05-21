import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/cart_item_model.dart';
import '../../domain/providers/cart_providers.dart';
import '../widgets/quantity_selector.dart';

/// Displays the user's shopping cart contents with quantity controls, a clear
/// all action, and a summary section showing subtotal, delivery fee, and total.
///
/// The bottom banner provides two actions: [Add Items] to continue shopping
/// at the same shop, and [Check out] with the total amount displayed inside
/// the button (navigates to checkout — placeholder for a future feature).
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
              onCheckout: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checkout coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
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
    final deliveryFee = _findDeliveryFee();

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

        // Summary section
        _CartSummary(
          subtotal: total,
          deliveryFee: deliveryFee,
          onAddItems: onAddItems,
          onCheckout: onCheckout,
        ),
      ],
    );
  }

  double _findDeliveryFee() {
    // If cart has items, try to get delivery fee from the shop. For now,
    // we use a placeholder since the cart doesn't store the full ShopModel.
    // This will be enhanced when checkout is implemented.
    // Returning 0 for simplicity — the fee will come from ShopModel in future.
    return 0.0;
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
// Cart Summary Bottom
// ============================================================================

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final VoidCallback? onAddItems;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.deliveryFee,
    this.onAddItems,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = subtotal + deliveryFee;

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
            // Subtotal
            _SummaryRow(
              label: 'Subtotal',
              value: '\$${subtotal.toStringAsFixed(2)}',
              textTheme: textTheme,
            ),
            const SizedBox(height: AppDimens.paddingXS),

            // Delivery fee
            _SummaryRow(
              label: 'Delivery fee',
              value: deliveryFee > 0
                  ? '\$${deliveryFee.toStringAsFixed(2)}'
                  : 'TBD at checkout',
              textTheme: textTheme,
              valueColor: deliveryFee > 0 ? null : AppColors.textHint,
            ),
            const SizedBox(height: AppDimens.paddingS),

            const Divider(height: 1),
            const SizedBox(height: AppDimens.paddingS),

            // Total
            _SummaryRow(
              label: 'Total',
              value: '\$${total.toStringAsFixed(2)}',
              textTheme: textTheme,
              isBold: true,
              valueColor: AppColors.primary,
            ),
            const SizedBox(height: AppDimens.paddingM),

            // Bottom actions: Add Items + Checkout
            Row(
              children: [
                // Add Items button
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: onAddItems ?? () {},
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add Items',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingM),

                // Checkout button with total amount
                Expanded(
                  child: SizedBox(
                    height: AppDimens.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: onCheckout,
                      icon: const Icon(Icons.shopping_cart_checkout_rounded),
                      label: Text(
                        'Check out \$${total.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimens.radiusM),
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

/// A single row in the cart summary (label | value).
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
