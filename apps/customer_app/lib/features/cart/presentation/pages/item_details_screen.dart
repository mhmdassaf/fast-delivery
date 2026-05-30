import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/item_detail_args.dart';
import '../../domain/providers/cart_providers.dart';
import '../widgets/quantity_selector.dart';

/// Full-screen item detail view shown when the user taps [+] on a menu item.
///
/// Receives an [ItemDetailArgs] via GoRouter's `extra` parameter containing
/// the [MenuItemModel] plus its shop context (shopId, shopName).
/// Allows the user to see the full image, description, add special instructions,
/// choose quantity, and add the item to their cart.
class ItemDetailsScreen extends ConsumerStatefulWidget {
  const ItemDetailsScreen({super.key});

  @override
  ConsumerState<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends ConsumerState<ItemDetailsScreen> {
  late final TextEditingController _instructionsController;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  ItemDetailArgs get _args {
    final extra = GoRouterState.of(context).extra;
    return extra is ItemDetailArgs
        ? extra
        : (throw ArgumentError(
            'ItemDetailsScreen requires ItemDetailArgs as route extra, '
            'got ${extra.runtimeType}'));
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final item = args.item;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Scrollable content ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item image
                  _ItemImage(imageUrl: item.imageUrl),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingM,
                      AppDimens.paddingL,
                      AppDimens.paddingM,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimens.paddingS),

                        // Full description
                        if (item.description != null &&
                            item.description!.isNotEmpty) ...[
                          Text(
                            item.description!,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            // No maxLines — show full description
                          ),
                          const SizedBox(height: AppDimens.paddingM),
                        ],

                        // Price
                        Text(
                          item.formattedPrice,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppDimens.paddingXL),

                        // Special Instructions
                        Text(
                          'Special Instructions',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingS),
                        TextField(
                          controller: _instructionsController,
                          maxLines: 3,
                          minLines: 3,
                          maxLength: 200,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText:
                                'E.g., no onions, extra sauce, allergies...',
                            hintStyle: textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusM,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(
                              AppDimens.paddingM,
                            ),
                          ),
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Fixed bottom bar ──────────────────────────────────────
          _BottomBar(
            quantity: _quantity,
            price: item.price,
            onQuantityChanged: (qty) {
              setState(() => _quantity = qty);
            },
            onAddToCart: () => _addToCart(context, args),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, ItemDetailArgs args) {
    final notifier = ref.read(cartNotifierProvider.notifier);
    final currentShopId = ref.read(cartShopIdProvider);

    // Guard: different shop?
    if (currentShopId != null && currentShopId != args.shopId) {
      _showDifferentShopDialog(context, args);
      return;
    }

    _performAdd(context, args, notifier);
  }

  void _performAdd(
    BuildContext context,
    ItemDetailArgs args,
    CartNotifier notifier,
  ) {
    final cartItem = CartItemModel(
      id: args.item.id,
      shopId: args.shopId,
      shopName: args.shopName,
      name: args.item.name,
      imageUrl: args.item.imageUrl,
      price: args.item.price,
      quantity: _quantity,
      specialInstructions: _instructionsController.text.trim(),
    );

    notifier.addOrUpdateItem(cartItem);

    // Pop back and show confirmation
    if (context.mounted) {
      context.pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${args.item.name} ×$_quantity added to cart'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: AppDimens.paddingM,
            right: AppDimens.paddingM,
            top: AppDimens.paddingM,
            // Clear the ViewCartBanner overlay
            bottom: AppDimens.cartBannerBottomPadding + AppDimens.paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
        ),
      );
    }
  }

  void _showDifferentShopDialog(BuildContext context, ItemDetailArgs args) {
    final currentShopName = ref.read(cartShopNameProvider) ?? 'another shop';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start a new cart?'),
        content: Text(
          'Your cart currently has items from $currentShopName. '
          'Would you like to clear it and start a new cart with items from '
          '${args.shopName}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              final notifier = ref.read(cartNotifierProvider.notifier);
              notifier.clearCart();
              _performAdd(context, args, notifier);
            },
            child: const Text('Start New'),
          ),
        ],
      ),
    );
  }
}

/// The full-width item image at the top of the details screen.
class _ItemImage extends StatelessWidget {
  final String? imageUrl;

  const _ItemImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 250,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: Icon(
                    Icons.restaurant_rounded,
                    size: AppDimens.iconXL,
                    color: AppColors.textHint,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _PlaceholderImage(),
            )
          : const _PlaceholderImage(),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: AppDimens.iconXL,
          color: AppColors.textHint.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Fixed bottom bar with quantity selector and Add to Cart button.
class _BottomBar extends StatelessWidget {
  final int quantity;
  final double price;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _BottomBar({
    required this.quantity,
    required this.price,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final total = price * quantity;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingM,
        AppDimens.paddingS,
        AppDimens.paddingM,
        AppDimens.cartBannerBottomPadding,
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
        child: Row(
          children: [
            // Quantity selector
            QuantitySelector(
              quantity: quantity,
              onChanged: onQuantityChanged,
            ),
            const SizedBox(width: AppDimens.paddingM),

            // Add to Cart button
            Expanded(
              child: SizedBox(
                height: AppDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusM),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Add to Cart  \$${total.toStringAsFixed(2)}',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimary,
                        ),
                        maxLines: 1,
                      ),
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
