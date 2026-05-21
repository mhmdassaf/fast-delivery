# Cart Feature Specification

> **AI-Readable Documentation for Cart Feature**  
> **Last Updated:** 2026-05-21  
> **Feature Status:** ✅ Implemented  
> **Commit:** `pending`  

---

## 📋 Feature Overview

**Purpose:** Shopping cart system for the Fast Delivery User App  
**Scope:** Add items to cart, manage quantities, special instructions, persistent cart storage, floating cart banner  
**Persistent Storage:** `shared_preferences` (cart survives app restarts)  
**Platform:** Flutter (Android, iOS)  
**Architecture:** App-specific feature (`apps/user_app/lib/features/cart/`)

---

## 📁 Files & Structure

```
apps/user_app/lib/features/cart/
├── data/
│   └── models/
│       ├── cart_item_model.dart           # Freezed data model
│       ├── cart_item_model.freezed.dart   # Generated
│       ├── cart_item_model.g.dart         # Generated
│       └── item_detail_args.dart          # Route arguments
├── domain/
│   └── providers/
│       ├── cart_providers.dart            # CartNotifier + derived providers
│       └── cart_providers.g.dart          # Generated
└── presentation/
    ├── pages/
    │   ├── item_details_screen.dart       # Full-screen item detail view
    │   └── my_cart_screen.dart            # Cart management screen
    └── widgets/
        ├── quantity_selector.dart         # Reusable [-] / [+] widget
        └── view_cart_banner.dart          # Floating bottom banner
```

### Supporting Changes in Other Files

| File | Change |
|------|--------|
| `packages/core/lib/constants/app_constants.dart` | Added `AppDimens.cartBannerBottomPadding = 88.0` |
| `packages/core/lib/errors/failure.dart` | Added `CartFailure` class |
| `apps/user_app/lib/main.dart` | ShellRoute wraps app routes with ViewCartBanner; new `/item-details` and `/my-cart` routes |
| `apps/user_app/lib/features/dashboard/presentation/pages/dashboard_screen.dart` | Added 88px bottom padding for ViewCartBanner overlay |
| `apps/user_app/lib/features/shop_details/presentation/pages/shop_details_screen.dart` | Added 88px bottom padding; [+] pushes to `/item-details` |
| `apps/user_app/lib/features/shop_details/presentation/widgets/menu_category_section.dart` | Passes `onItemAddTap` callback |
| `apps/user_app/lib/features/shop_details/presentation/widgets/menu_item_card.dart` | Simplified; removed SnackBar placeholder |
| `docs/shop_details_feature.md` | Updated with cart integration details |

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure (in `apps/user_app/lib/features/cart/`)

```
lib/features/cart/
├── data/                         # Data layer
│   └── models/
│       ├── cart_item_model.dart   # Freezed model with JSON serialization
│       └── item_detail_args.dart  # GoRouter extra arguments
├── domain/                       # Domain layer
│   └── providers/
│       └── cart_providers.dart    # CartNotifier + derived Riverpod providers
└── presentation/                 # Presentation layer
    ├── pages/
    │   ├── item_details_screen.dart  # Item detail with add-to-cart
    │   └── my_cart_screen.dart       # Cart list + summary
    └── widgets/
        ├── quantity_selector.dart    # Reusable quantity control
        └── view_cart_banner.dart     # Animated floating banner
```

### Key Principles
- **Data Layer:** Defines `CartItemModel` (Freezed) with JSON serialization for persistence
- **Domain Layer:** Contains `CartNotifier` (Riverpod) managing cart state with `shared_preferences` persistence
- **Presentation Layer:** UI components consuming providers via `ConsumerWidget`/`ConsumerStatefulWidget`
- **No Firebase dependency:** Cart data is local-only (no Firestore), persisted via `shared_preferences`

---

## 🛒 Cart Flows

### 1. Add Item to Cart
**Entry Point:** `shop_details_screen.dart` → `menu_item_card.dart` [+] button
**Flow:**
1. User taps [+] on a menu item in `MenuCategorySection`
2. `onItemAddTap` callback pushes to `/item-details` with `ItemDetailArgs`
3. `ItemDetailsScreen` receives args via `GoRouterState.of(context).extra`
4. User views full description, sets quantity, adds special instructions
5. User taps "Add to Cart" button
6. `CartNotifier.addOrUpdateItem()` is called:
   - If item exists → increments quantity
   - If new item → appends to list
7. Cart state is saved to `shared_preferences`
8. `ViewCartBanner` slides up (via `hasCartItemsProvider` change)
9. Screen pops back; SnackBar confirmation shown

### 2. Quantity Management in Cart
**Entry Point:** `my_cart_screen.dart`
- Tap [-] on a cart item → `CartNotifier.updateQuantity(id, qty - 1)`
- Tap [+] on a cart item → `CartNotifier.updateQuantity(id, qty + 1)`
- If quantity drops to 0 → `CartNotifier.removeItem(id)` is called
- Changes auto-persist to `shared_preferences`

### 3. Clear Cart
**Entry Point:** `my_cart_screen.dart` AppBar delete icon
1. Confirmation dialog shown
2. On confirm → `CartNotifier.clearCart()`
3. State resets to `[]`; `shared_preferences` updated
4. `ViewCartBanner` slides down

### 4. Cross-Shop Guard
When user tries to add an item from a different shop:
1. `ItemDetailsScreen._addToCart()` checks `cartShopIdProvider`
2. If different shop → dialog: "Start a new cart?"
3. "Cancel" → dialog closes, no change
4. "Start New" → `CartNotifier.clearCart()` then new item added

---

## 📊 State Management (Riverpod)

### Providers (in `apps/user_app/lib/features/cart/domain/providers/cart_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `cartNotifierProvider` | `@riverpod` Notifier | **Core state** - `CartNotifier` with `List<CartItemModel>` |
| `cartItemCountProvider` | `@riverpod` | Total item count (sum of quantities) |
| `cartTotalProvider` | `@riverpod` | Total price of all items |
| `cartShopIdProvider` | `@riverpod` | Shop ID of items in cart (null if empty) |
| `cartShopNameProvider` | `@riverpod` | Shop name of items in cart (null if empty) |
| `hasCartItemsProvider` | `@riverpod` | Boolean: whether cart has items |

### CartNotifier State
```dart
// State: List<CartItemModel>
// Initial: [] (empty list while prefs load asynchronously)
```

### CartNotifier Methods
| Method | Description |
|--------|-------------|
| `addOrUpdateItem(CartItemModel item)` | Add new item or increment quantity of existing |
| `updateQuantity(String itemId, int quantity)` | Set specific quantity; removes if < 1 |
| `updateInstructions(String itemId, String instructions)` | Update special instructions |
| `removeItem(String itemId)` | Remove item entirely |
| `clearCart()` | Remove all items |

### Persistence
- Async initialization via `WidgetsBinding.instance.addPostFrameCallback`
- `_initPrefs()` → `SharedPreferences.getInstance()` → `_loadFromPrefs()`
- `_saveToPrefs()` called after every mutation
- JSON encoded/decoded: `jsonEncode(state.map((e) => e.toJson()).toList())`
- Graceful failure: if prefs unavailable or decode fails, starts with empty cart

---

## 🧭 Navigation (GoRouter)

**Router Config:** `apps/user_app/lib/main.dart` → `routerProvider`

### Route Structure
```
/login            ← Auth route (outside ShellRoute — no cart banner)
/register         ← Auth route (outside ShellRoute — no cart banner)
/                 ← Dashboard (inside ShellRoute with ViewCartBanner)
/shop/:shopId     ← Shop details (inside ShellRoute)
/item-details     ← Item detail + add to cart (inside ShellRoute)
/my-cart          ← Cart management (inside ShellRoute)
```

### ShellRoute
```dart
ShellRoute(
  builder: (context, state, child) => Stack(
    children: [
      child,
      const Align(
        alignment: Alignment.bottomCenter,
        child: ViewCartBanner(),
      ),
    ],
  ),
  // ... app routes
)
```

### Route Arguments
- `/item-details` → `GoRouterState.of(context).extra` expects `ItemDetailArgs`
- `ItemDetailArgs` holds: `MenuItemModel item`, `String shopId`, `String shopName`

---

## 🎨 UI Components

### Screens

| Screen | File | Purpose |
|--------|------|---------|
| `ItemDetailsScreen` | `pages/item_details_screen.dart` | Full-screen item view, quantity selector, instructions, add to cart |
| `MyCartScreen` | `pages/my_cart_screen.dart` | Cart items list, summary, checkout placeholder |

### Widgets

| Widget | File | Purpose |
|--------|------|---------|
| `QuantitySelector` | `widgets/quantity_selector.dart` | Horizontal [-] / [+] buttons with count display |
| `ViewCartBanner` | `widgets/view_cart_banner.dart` | Animated floating banner (slide up/down) with item count + total |
| `_CircleButton` | `widgets/quantity_selector.dart` | Circular icon button for quantity controls |
| `_ItemImage` | `pages/item_details_screen.dart` | Full-width item image with placeholder |
| `_PlaceholderImage` | `pages/item_details_screen.dart` | Fallback when no image URL |
| `_BottomBar` | `pages/item_details_screen.dart` | Fixed bottom bar with quantity + add-to-cart |
| `_CartItemCard` | `pages/my_cart_screen.dart` | Cart item row with image, name, instructions, price, quantity |
| `_CartSummary` | `pages/my_cart_screen.dart` | Subtotal/delivery/total summary with actions |
| `_EmptyCart` | `pages/my_cart_screen.dart` | Empty cart illustration with "Browse Shops" CTA |
| `_SummaryRow` | `pages/my_cart_screen.dart` | Single label/value row in summary |

### ViewCartBanner Animation
- Uses `AnimationController` with `SlideTransition` (Offset from (0,1) to (0,0))
- Duration: 300ms, curve: `easeOutCubic`
- Controlled via `_hasItems` tracked field (not side-effects in `build()`)
- Shows: cart icon, item count, total price, "View Cart" button

### QuantitySelector
- Configurable `min` (default 1) and `max` (default null = no limit)
- `min: 0` used in cart screen to allow removal by decrementing to zero
- Circular `_CircleButton` with enabled/disabled styling

---

## 💾 Data Models

### CartItemModel (Freezed)
**File:** `apps/user_app/lib/features/cart/data/models/cart_item_model.dart`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `String` | required | Menu item ID from Firestore |
| `shopId` | `String` | required | Shop the item belongs to |
| `shopName` | `String` | required | Cached shop display name |
| `name` | `String` | required | Menu item display name |
| `imageUrl` | `String?` | null | Optional item image URL |
| `price` | `double` | 0.0 | Unit price |
| `quantity` | `int` | 1 | Quantity (minimum 1) |
| `specialInstructions` | `String` | '' | User-provided instructions |

**Computed property:** `totalPrice` → `price * quantity`

### ItemDetailArgs
**File:** `apps/user_app/lib/features/cart/data/models/item_detail_args.dart`

| Field | Type | Description |
|-------|------|-------------|
| `item` | `MenuItemModel` | The menu item being viewed |
| `shopId` | `String` | Shop ID (not in MenuItemModel) |
| `shopName` | `String` | Shop name (for display + cross-shop guard) |

---

## 🎨 Theming

Uses existing `AppColors` and `AppDimens` from `packages/core/lib/constants/app_constants.dart`:

### AppDimens (Additions for Cart)
| Constant | Value | Usage |
|----------|-------|-------|
| `cartBannerBottomPadding` | 88.0 | Bottom padding on scrollable content behind ViewCartBanner |

### CartFailure (in `packages/core/lib/errors/failure.dart`)
| Factory | Message |
|---------|---------|
| `CartFailure.emptyCart()` | "Cart is empty" |
| `CartFailure.addToCartFailed()` | "Failed to add item to cart" |
| `CartFailure.persistFailed()` | "Failed to save cart data" |

---

## 📦 Dependencies (in `apps/user_app/pubspec.yaml`)

### Packages used by Cart Feature
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod code gen |
| `shared_preferences` | ^2.5.3 | Cart persistence |
| `go_router` | ^14.8.1 | Navigation |
| `cached_network_image` | ^3.4.1 | Item image loading |
| `freezed_annotation` | ^3.0.0 | CartItemModel |
| `json_annotation` | ^4.9.0 | JSON serialization |

### Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.15 | Code generation |
| `freezed` | ^3.0.0 | Freezed code gen |
| `json_serializable` | ^6.9.4 | JSON code gen |
| `riverpod_generator` | ^2.6.5 | Riverpod code gen |

---

## 🔄 How to Modify This Feature

### Adding a New Field to CartItemModel
1. Add field to `CartItemModel` in `data/models/cart_item_model.dart`
2. Run `dart run build_runner build --delete-conflicting-outputs` in `apps/user_app/`
3. Update `CartNotifier` if the field needs special handling
4. Update **this doc** with new field

### Adding a New Cart Mutation
1. Add method to `CartNotifier` in `domain/providers/cart_providers.dart`
2. Call `_saveToPrefs()` after state change
3. Expose via UI in `my_cart_screen.dart` or `item_details_screen.dart`
4. Update **this doc**

### Adding a New Derived Provider
1. Add `@riverpod` annotated function in `domain/providers/cart_providers.dart`
2. Run `dart run build_runner build --delete-conflicting-outputs` in `apps/user_app/`
3. Use in UI via `ref.watch(yourProvider)`
4. Update **this doc**

---

## ⚠️ Error Handling

### Graceful Degradation
- If `shared_preferences` is unavailable → cart starts empty (no crash)
- If JSON decode fails → cart resets to empty (no crash)
- If `shared_preferences.save()` fails → cart state preserved in memory (silent failure)
- All error paths are logged via try/catch with no rethrow

### CartFailure Types (available but not yet actively used in UI)
- Used for future integration with `Result<T>` pattern
- Currently, mutations are void methods with silent error handling

---

## 🧪 Testing (TODO)

**Current Tests:** None specific to cart feature  
**Existing General Tests:** `test/widget_test.dart` - Basic smoke test (2 tests pass)  
**Future Tests Needed:**
- Unit tests for `CartNotifier` (add, update, remove, clear)
- Unit tests for persistence (shared_preferences mock)
- Widget tests for `ItemDetailsScreen`
- Widget tests for `MyCartScreen` (empty + populated states)
- Widget tests for `QuantitySelector`
- Widget tests for `ViewCartBanner` (animation states)
- Integration tests for add-to-cart flow

---

## 📝 Conventions for Future Changes

### ✅ DO:
1. **Use `CartNotifier` methods** for all cart mutations
2. **Derive state** from existing providers (e.g., `cartItemCountProvider`)
3. **Use `AppDimens` and `AppColors`** from `packages/core/`
4. **Handle persistence** via `_saveToPrefs()` in `CartNotifier`
5. **Use callbacks** in private widget classes (avoid `WidgetRef ref` anti-pattern)
6. **Track animation state** with instance fields (avoid side-effects in `build()`)
7. **Generate code** after changing providers/models:
   ```bash
   cd apps/user_app
   dart run build_runner build --delete-conflicting-outputs
   ```

### ❌ DON'T:
1. **Don't call `shared_preferences` directly from UI** - go through `CartNotifier`
2. **Don't modify state outside `CartNotifier`** - always use notifier methods
3. **Don't hardcode colors/spacing** - use theme constants from `packages/core/`
4. **Don't skip `_saveToPrefs()`** after mutations
5. **Don't put business logic in widget classes**
6. **Don't forget to dispose** `TextEditingController` and `FocusNode` in State

---

## 🚀 Quick Reference for AI Agents

**When modifying the cart feature, always:**
1. Read this file first (`docs/cart_feature.md`)
2. Follow Clean Architecture layers (data/models → domain/providers → presentation/pages+widgets)
3. Use `CartNotifier` for all state changes
4. Persist changes via `_saveToPrefs()` in `CartNotifier`
5. Use `AppColors`/`AppDimens` from `package:fast_delivery_core/constants/app_constants.dart`
6. Use callbacks for private widgets (not `WidgetRef ref`)
7. Run `build_runner` after provider/model changes
8. Update **this doc** after making changes

**Key Files to Review:**
- `apps/user_app/lib/features/cart/domain/providers/cart_providers.dart` - State management
- `apps/user_app/lib/features/cart/data/models/cart_item_model.dart` - Data model
- `apps/user_app/lib/features/cart/presentation/pages/item_details_screen.dart` - Item detail UI
- `apps/user_app/lib/features/cart/presentation/pages/my_cart_screen.dart` - Cart management UI
- `apps/user_app/lib/features/cart/presentation/widgets/view_cart_banner.dart` - Banner widget
- `apps/user_app/lib/main.dart` - Router configuration
- `packages/core/lib/constants/app_constants.dart` - AppDimens
- `packages/core/lib/errors/failure.dart` - CartFailure

**Common Pitfalls:**
- Forgetting to run `build_runner` after provider/model changes
- Not disposing `TextEditingController` in `ItemDetailsScreen`
- Calling `SharedPreferences.getInstance()` from UI instead of through `CartNotifier`
- Hardcoding colors instead of using `AppColors`
- Adding animation side-effects in `build()` (see `ViewCartBanner` fix)
- Passing `WidgetRef` to private widget classes instead of callbacks (see `MyCartScreen` fix)

---

**End of Cart Feature Specification**
