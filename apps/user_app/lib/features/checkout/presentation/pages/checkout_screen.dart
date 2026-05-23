import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fast_delivery_core/constants/app_constants.dart';

import '../../../cart/domain/providers/cart_providers.dart';
import '../../data/models/delivery_address_model.dart';
import '../../domain/providers/checkout_providers.dart';
import '../widgets/delivery_address_section.dart';
import '../widgets/delivery_time_section.dart';
import '../widgets/order_summary_section.dart';
import '../widgets/phone_number_section.dart';
import '../widgets/place_order_banner.dart';

/// The checkout screen where users review their order summary, set a delivery
/// address, and place the order.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _lastHandledOrderId;

  void _onOrderPlaced(String orderId) {
    _lastHandledOrderId = orderId;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Order placed successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'OK',
          textColor: AppColors.onPrimary,
          onPressed: () {},
        ),
      ),
    );
    context.go('/');
  }

  Future<void> _onChangeAddress() async {
    final action = await showAddressOptionsSheet(context);
    if (action == null || !mounted) return;

    final notifier = ref.read(checkoutNotifierProvider.notifier);

    switch (action) {
      case AddressAction.useDevice:
        await notifier.useDeviceLocation();
      case AddressAction.setManual:
        final address = await _showManualAddressDialog();
        if (address != null && mounted) {
          notifier.setAddress(address);
        }
    }
  }

  Future<DeliveryAddressModel?> _showManualAddressDialog() async {
    return showDialog<DeliveryAddressModel>(
      context: context,
      builder: (_) => const _ManualAddressDialog(),
    );
  }

  Future<void> _onPlaceOrder() async {
    final notifier = ref.read(checkoutNotifierProvider.notifier);
    final result = await notifier.placeOrder();

    result.fold(
      onSuccess: (_) {
        // Navigation handled by the listener in build()
      },
      onFailure: (failure) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutNotifierProvider);
    final subtotal = ref.watch(cartTotalProvider);

    // Listen for successful order creation to navigate away
    ref.listen(checkoutNotifierProvider, (previous, next) {
      final orderId = next.createdOrderId;
      if (orderId != null && orderId != _lastHandledOrderId) {
        _onOrderPlaced(orderId);
      }
      // Show error messages (e.g. location failures) as SnackBar
      final errorMessage = next.errorMessage;
      if (errorMessage != null && errorMessage != previous?.errorMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppDimens.paddingS,
                bottom: AppDimens.paddingM,
              ),
              children: [
                // Delivery Time
                DeliveryTimeSection(
                  deliveryTimeLabel: state.deliveryTimeLabel,
                  isLoading: state.isLoadingShopInfo,
                ),

                const SizedBox(height: AppDimens.paddingXS),

                // Delivery Address
                DeliveryAddressSection(
                  address: state.deliveryAddress,
                  onChangePressed: _onChangeAddress,
                ),

                const SizedBox(height: AppDimens.paddingXS),

                // Phone Number (mandatory — rider contact)
                const PhoneNumberSection(),

                const SizedBox(height: AppDimens.paddingXS),

                // Order Summary
                OrderSummarySection(
                  subtotal: subtotal,
                  deliveryFee: state.deliveryFee,
                ),

                // Extra bottom padding so content doesn't hide behind banner
                const SizedBox(height: AppDimens.paddingL),
              ],
            ),
          ),

          // Fixed bottom banner
          PlaceOrderBanner(
            subtotal: subtotal,
            deliveryFee: state.deliveryFee,
            isLoading: state.isLoadingShopInfo,
            isPlacingOrder: state.isPlacingOrder,
            onPlaceOrder: _onPlaceOrder,
          ),
        ],
      ),
    );
  }
}

/// A stateful dialog widget for manually entering a delivery address.
///
/// Owns its [TextEditingController] and [FormState] to ensure proper
/// lifecycle management and avoid recreation on parent rebuilds.
class _ManualAddressDialog extends StatefulWidget {
  const _ManualAddressDialog();

  @override
  State<_ManualAddressDialog> createState() => _ManualAddressDialogState();
}

class _ManualAddressDialogState extends State<_ManualAddressDialog> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: AlertDialog(
        title: const Text('Enter Address'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'e.g. 123 Main St, City',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an address';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(
                  DeliveryAddressModel(
                    latitude: 0.0,
                    longitude: 0.0,
                    addressLine: _addressController.text.trim(),
                    label: 'Manual',
                  ),
                );
              }
            },
            child: Text(
              'Set Address',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
