import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/cart_item_model.dart';

part 'cart_providers.g.dart';

/// Key used to persist the cart list in shared_preferences.
const _kCartPrefsKey = 'cart_items';

// ============================================================================
// Cart Notifier (State Management)
// ============================================================================

/// Notifier for the user's shopping cart.
///
/// State is persisted to local storage via shared_preferences so it survives
/// app restarts. The initial state is an empty list while prefs load asynchronously.
@riverpod
class CartNotifier extends _$CartNotifier {
  SharedPreferences? _prefs;

  @override
  List<CartItemModel> build() {
    // Load from local storage after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPrefs();
    });
    return [];
  }

  // ==========================================================================
  // Initialization
  // ==========================================================================

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // SharedPreferences unavailable — start with empty cart.
      return;
    }
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    try {
      final json = _prefs?.getString(_kCartPrefsKey);
      if (json == null || json.isEmpty) return;
      final list = jsonDecode(json) as List;
      state = list
          .map((e) =>
              CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // If decoding fails, start with an empty cart.
      state = [];
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((e) => e.toJson()).toList());
      await prefs.setString(_kCartPrefsKey, json);
    } catch (_) {
      // Silently fail — cart state is still valid in memory.
    }
  }

  // ==========================================================================
  // Mutations
  // ==========================================================================

  /// Add an item to the cart or increment its quantity if it already exists.
  void addOrUpdateItem(CartItemModel item) {
    final index = state.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      // Item exists — increment quantity.
      final existing = state[index];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            existing.copyWith(quantity: existing.quantity + item.quantity)
          else
            state[i],
      ];
    } else {
      // New item
      state = [...state, item];
    }
    _saveToPrefs();
  }

  /// Set a specific quantity for an item. If quantity drops to 0, remove it.
  void updateQuantity(String itemId, int quantity) {
    if (quantity < 1) {
      removeItem(itemId);
      return;
    }
    final index = state.indexWhere((e) => e.id == itemId);
    if (index < 0) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(quantity: quantity) else state[i],
    ];
    _saveToPrefs();
  }

  /// Update special instructions for an item.
  void updateInstructions(String itemId, String instructions) {
    final index = state.indexWhere((e) => e.id == itemId);
    if (index < 0) return;
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(specialInstructions: instructions)
        else
          state[i],
    ];
    _saveToPrefs();
  }

  /// Remove an item from the cart entirely.
  void removeItem(String itemId) {
    state = state.where((e) => e.id != itemId).toList();
    _saveToPrefs();
  }

  /// Clear all items from the cart.
  void clearCart() {
    state = [];
    _saveToPrefs();
  }
}

// ============================================================================
// Derived Providers
// ============================================================================

/// Number of distinct items in the cart (cart entry count).
@riverpod
int cartItemCount(Ref ref) {
  final cart = ref.watch(cartNotifierProvider);
  return cart.length;
}

/// Total price of all items in the cart.
@riverpod
double cartTotal(Ref ref) {
  final cart = ref.watch(cartNotifierProvider);
  if (cart.isEmpty) return 0.0;
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
}

/// The [shopId] of items currently in the cart.
///
/// Returns `null` when the cart is empty. If items from multiple shops end up
/// in the cart (edge case), returns the first shop's ID.
@riverpod
String? cartShopId(Ref ref) {
  final cart = ref.watch(cartNotifierProvider);
  if (cart.isEmpty) return null;
  return cart.first.shopId;
}

/// The [shopName] of items currently in the cart.
@riverpod
String? cartShopName(Ref ref) {
  final cart = ref.watch(cartNotifierProvider);
  if (cart.isEmpty) return null;
  return cart.first.shopName;
}

/// Whether any cart items exist.
@riverpod
bool hasCartItems(Ref ref) {
  final count = ref.watch(cartItemCountProvider);
  return count > 0;
}
