# Shop Details & Menu Feature Specification

> **AI-Readable Documentation for Shop Details & Menu Feature**  
> **Last Updated:** 2026-05-21  
> **Feature Status:** ✅ Implemented  
> **Commit:** *(pending — will be committed after review)*

---

## 📋 Feature Overview

**Purpose:** Display shop details and menu when a user taps a shop card on the dashboard  
**Scope:** Shop info (cover, logo, rating, delivery), menu items organized by category, full cart flow (item details → add to cart → view cart → my cart screen)  
**Roles Supported:** `user`, `rider`, `seller`, `admin`  
**Platform:** Flutter (iOS, Android, Web)  
**Architecture:** App-local feature (uses shared `fast_delivery_core` package)

---

## 📦 Feature Structure

```
apps/user_app/lib/features/
├── shop_details/                               # Shop details & menu browsing
│   ├── data/
│   │   ├── datasources/
│   │   │   └── shop_details_datasource.dart
│   │   ├── models/
│   │   │   ├── menu_item_group.dart
│   │   │   ├── menu_item_model.dart
│   │   │   ├── menu_item_model.freezed.dart
│   │   │   └── menu_item_model.g.dart
│   │   └── repositories/
│   │       └── shop_details_repository.dart
│   ├── domain/
│   │   └── providers/
│   │       ├── shop_details_providers.dart
│   │       └── shop_details_providers.g.dart
│   └── presentation/
│       ├── pages/
│       │   └── shop_details_screen.dart
│       └── widgets/
│           ├── menu_category_section.dart
│           ├── menu_item_card.dart
│           ├── shop_details_error_state.dart
│           ├── shop_details_skeleton.dart
│           └── shop_header_section.dart
│
└── cart/                                      # Shopping cart feature
    ├── data/
    │   └── models/
    │       ├── cart_item_model.dart            # Freezed model with JSON serialization
    │       ├── cart_item_model.freezed.dart
    │       ├── cart_item_model.g.dart
    │       └── item_detail_args.dart           # Args for ItemDetailsScreen navigation
    ├── domain/
    │   └── providers/
    │       ├── cart_providers.dart             # CartNotifier + derived providers
    │       └── cart_providers.g.dart
    └── presentation/
        ├── pages/
        │   ├── item_details_screen.dart        # Full item detail + add to cart
        │   └── my_cart_screen.dart             # Cart management & summary
        └── widgets/
            ├── quantity_selector.dart          # Reusable -/+ widget
            └── view_cart_banner.dart           # Global floating cart banner
```

### Package Dependencies:
- **fast_delivery_core** — Used for `AppColors`, `AppDimens`, `Failure`/`Result` types
- **fast_delivery_auth** — Used for `authStatusProvider` (via shared router redirect)
- **dashboard feature** — Uses `ShopModel` from `features/dashboard/data/models/shop_model.dart`

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure

```
apps/user_app/lib/features/shop_details/
├── data/
│   ├── datasources/
│   │   └── shop_details_datasource.dart       # Firestore queries for shop + menu_items subcollection
│   ├── models/
│   │   ├── menu_item_model.dart               # Freezed model with fromFirestore()
│   │   └── menu_item_group.dart               # category + items list grouping
│   └── repositories/
│       └── shop_details_repository.dart        # Repository interface + Firestore impl
├── domain/
│   └── providers/
│       ├── shop_details_providers.dart         # Riverpod providers + ShopDetailsNotifier
│       └── shop_details_providers.g.dart
└── presentation/
    ├── pages/
    │   └── shop_details_screen.dart           # Main scrollable screen
    └── widgets/
        ├── shop_header_section.dart            # Cover image, logo overlay, name, rating, delivery info
        ├── menu_category_section.dart          # Category header + list of MenuItemCards
        ├── menu_item_card.dart                 # Card: image, title, description, price, add button
        ├── shop_details_skeleton.dart          # Shimmer loading skeleton
        └── shop_details_error_state.dart       # Error state with retry button
```

### Key Principles
- **Data Layer:** Handles Firestore queries for shop document and `menu_items` subcollection via `ShopDetailsDataSourceImpl`
- **Domain Layer:** Contains business logic via Riverpod `ShopDetailsNotifier` — fetches shop + menu in parallel, groups items by category
- **Presentation Layer:** Composable widgets consuming provider data via `ConsumerWidget`
- **Core Layer:** Shared utilities from `packages/core/` (theme, errors, result pattern)

### Data Flow
```
User taps shop card → GoRouter /shop/:shopId → ShopDetailsScreen
  → ShopDetailsNotifier.loadShopDetails()
  → Future.wait([getShopById, getMenuItems]) → ShopDetailsDataSource → Firestore
  → ShopDetailsState update → UI rebuild
```

### Grouping Strategy
Menu items are stored flat in the `menu_items` subcollection with a `category` field (string). On the client side, `ShopDetailsState.groupItems()` groups them by category into `MenuItemGroup` objects, preserving the `order`-based sort within each group.

---

## 📊 State Management (Riverpod)

### Providers (in `domain/providers/shop_details_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `shopDetailsFirebaseFirestoreProvider` | `@riverpod` (AutoDispose) | Exposes `FirebaseFirestore.instance` |
| `shopDetailsDataSourceProvider` | `@riverpod` (AutoDispose) | Creates `ShopDetailsDataSourceImpl` |
| `shopDetailsRepositoryProvider` | `@riverpod` (AutoDispose) | Creates `ShopDetailsRepositoryImpl` |
| `shopDetailsNotifierProvider` | `@riverpod` (Notifier, family) | **Main state manager** — scoped by `shopId` |

### ShopDetailsNotifier State
```dart
class ShopDetailsState {
  final ShopModel? shop;                    // Loaded shop (null while loading / on error)
  final List<MenuItemModel> menuItems;       // All fetched menu items
  final List<MenuItemGroup> groupedMenuItems; // Items grouped by category
  final bool isLoading;                      // Initial loading state
  final String? errorMessage;                // Error state
}
```

### ShopDetailsNotifier Methods

| Method | Purpose |
|--------|---------|
| `build(String shopId)` | Initialize notifier, auto-trigger `loadShopDetails()` via `addPostFrameCallback` |
| `loadShopDetails()` | Fetch shop + menu items in parallel, group items by category |
| `clearError()` | Dismiss error message |

### Derived State
- `hasMenuItems` — `menuItems.isNotEmpty`
- `hasError` — `errorMessage != null`

---

## 🧭 Navigation (GoRouter)

**Router Config:** Defined in `apps/user_app/lib/main.dart` via `routerProvider`

### ShellRoute Structure

Auth routes (`/login`, `/register`) sit **outside** the ShellRoute to avoid showing the cart banner on auth screens. All app routes sit **inside** the ShellRoute, which wraps them in a `Stack` with a `ViewCartBanner` at the bottom.

```dart
GoRouter(
  routes: [
    // Auth routes (no banner)
    GoRoute(path: '/login', ...),
    GoRoute(path: '/register', ...),

    // App shell (with ViewCartBanner)
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
      routes: [
        GoRoute(path: '/', ...),                     // DashboardScreen
        GoRoute(path: '/shop/:shopId', ...),          // ShopDetailsScreen
        GoRoute(path: '/item-details', ...),           // ItemDetailsScreen
        GoRoute(path: '/my-cart', ...),                // MyCartScreen
      ],
    ),
  ],
)
```

### Route Details

| Route | Args | Screen |
|-------|------|--------|
| `/` | — | `DashboardScreen` |
| `/shop/:shopId` | `shopId` from path | `ShopDetailsScreen` |
| `/item-details` | `ItemDetailArgs` via `state.extra` | `ItemDetailsScreen` |
| `/my-cart` | — | `MyCartScreen` |

### Navigation Examples

```dart
// Dashboard → Shop details
context.push('/shop/${shop.id}');

// MenuItemCard [+] → Item details
context.push('/item-details', extra: ItemDetailArgs(
  item: menuItem,
  shopId: shopId,
  shopName: shop.name,
));

// ViewCartBanner → My cart
context.push('/my-cart');
```

---

## 🔥 Firebase Integration

### Firestore Collections Used

#### `shops/{shopId}` (existing)

Existing `ShopModel` with fields: `name`, `categoryId`, `shortDescription`, `tags`, `logoUrl`, `coverImageUrl`, `rating`, `ratingCount`, `deliveryTime`, `deliveryFee`, `minOrderAmount`, `isOpen`, `address`, `latitude`, `longitude`, `isActive`, `createdAt`, `updatedAt`

#### `shops/{shopId}/menu_items/{itemId}` (NEW — subcollection)

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Item display name |
| `description` | String? | Optional description |
| `imageUrl` | String? | Optional item image URL |
| `price` | Number | Price in USD (always USD per app requirements) |
| `category` | String | Menu category name (e.g. "Combos", "Salads", "Sandwiches") |
| `isAvailable` | Boolean | Whether item can be ordered |
| `order` | Number | Display sort order within category (ascending) |
| `isPopular` | Boolean | Whether item is marked as popular |
| `isActive` | Boolean | Soft-delete flag |
| `createdAt` | Timestamp | Creation time |
| `updatedAt` | Timestamp | Last update |

### Data Source Methods (in `shop_details_datasource.dart`)

| Method | Purpose |
|--------|---------|
| `getShopById(shopId)` | Fetch single shop document by ID |
| `getMenuItems(shopId)` | Fetch all active + available menu items, ordered by `order` asc |

### Query Strategy
1. **Shop document:** Direct `doc(shopId).get()` — single document read
2. **Menu items:** Subcollection query — `where('isActive', ==, true)` + `orderBy('order')` → client-side filter `isAvailable == true`
3. **Parallel fetch:** Both queries run simultaneously via `Future.wait`

### Security Rules (in `firestore.rules`)

**Menu Items (subcollection):**
```javascript
match /shops/{shopId}/menu_items/{itemId} {
  allow read: if isAuthenticated();
  allow create: if hasRole('seller') && 
    get(/databases/$(database)/documents/shops/$(shopId)).data.sellerId == request.auth.uid;
  allow update: if hasRole('seller') && 
    get(/databases/$(database)/documents/shops/$(shopId)).data.sellerId == request.auth.uid &&
    request.resource.data.keys().hasAny(['name', 'description', 'imageUrl',
      'price', 'category', 'isAvailable', 'order', 'isPopular', 'updatedAt']);
  allow read, write: if isAdmin();
  allow delete: if false;
}
```

### Composite Indexes (in `firestore.indexes.json`)

```json
{
  "collectionGroup": "menu_items",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "isActive", "order": "ascending" },
    { "fieldPath": "order", "order": "ascending" }
  ]
}
```

---

## 🎨 UI Components

### Shop Details Screen Structure (vertical scroll with slivers)

```
┌─ AppBar (back ← shop name) ──────────────────┐
│                                                │
│  ┌── ShopHeaderSection ─────────────────────┐ │
│  │  [Cover Image with gradient]             │ │
│  │       [Logo]                             │ │
│  │  Shop Name                               │ │
│  │  ★ 4.5 (234 ratings)                     │ │
│  │  🟢 Open • 25-35 min • $2.99             │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  Our Menu                                     │
│                                                │
│  ── Combos ───────────────────────────────    │
│  ┌─ MenuItemCard ──────────────────────────┐ │
│  │  [Image]  Mega Combo Pizza              │ │
│  │            Large pizza with drink        │ │
│  │            $12.99                [+ add] │ │
│  └──────────────────────────────────────────┘ │
│  ┌─ MenuItemCard ──────────────────────────┐ │
│  │  [Image]  Healthy Combo                 │ │
│  │            Salad + juice combo           │ │
│  │            $8.99                 [+ add] │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ── Salads ───────────────────────────────    │
│  ┌─ MenuItemCard ──────────────────────────┐ │
│  │  ...                                     │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

### Widgets Catalog

| Widget | Purpose | Key Features |
|--------|---------|--------------|
| `ShopHeaderSection` | Shop profile header | 200dp cover image with gradient overlay, circular logo offset, name, star rating with count, open/closed badge, delivery time + fee |
| `MenuItemCard` | Individual menu item | 80×80 image left, title (1 line), description (2 lines), price USD, add icon button → navigates to ItemDetailsScreen |
| `MenuCategorySection` | Category grouping | Bold category name with divider line + item count, list of MenuItemCards with onItemAddTap callback |
| `ShopDetailsSkeleton` | Loading skeleton | Shimmer matching full layout: cover, logo, name, rating, category sections with card placeholders |
| `ShopDetailsErrorState` | Error display | Error icon, title, message, "Try Again" button |
| `_EmptyMenuState` | No menu state (private) | "Menu coming soon" with restaurant icon, hint text; defined inside `shop_details_screen.dart` |
| `ItemDetailsScreen` | Full item detail + add to cart | 250dp full-width image, full description, price, special instructions text area, quantity selector, Add to Cart button (fixed bottom bar) |
| `MyCartScreen` | Cart management | Item list with qty controls, remove button, Clear All, summary (subtotal, delivery fee, total), disabled "Proceed to Checkout" placeholder |
| `QuantitySelector` | Reusable -/+ widget | Circular buttons, configurable min/max, compact horizontal layout |
| `ViewCartBanner` | Global cart banner | Animated slide-up, shows item count + total, "View Cart" button, appears on all ShellRoute-wrapped screens |

### Overflow Prevention (per SKILL.md)
- Every `Text` has `maxLines` + `TextOverflow.ellipsis`
- `Flexible`/`Expanded` used inside Rows for variable-width children
- Cover image uses `Positioned.fill` to fill available space
- Menu item cards use single-column `SliverList` (no grid overflow issues)
- Category dividers use `Expanded` for the line

### Formatted Values
- **Price:** `12.99` → `"$12.99"` (always USD)
- **Delivery Fee:** `0.0` → `"Free"`, otherwise `"$2.99"` (from ShopModel)
- **Rating:** `4.5` → `"4.5 (234)"` (from ShopModel)
- **Rating Count:** `1234` → `"1.2K"`
- **Delivery Time:** Raw string from Firestore (e.g. `"25-35 min"`)

### Add to Cart Flow

1. **Tap [+] on MenuItemCard** → calls `onAddTap` callback provided by `ShopDetailsScreen`
2. **Navigation**: `ShopDetailsScreen` pushes `/item-details` route via GoRouter, passing an `ItemDetailArgs` (containing `MenuItemModel`, `shopId`, `shopName`) via `extra`
3. **ItemDetailsScreen** displays:
   - Full-width 250dp image
   - Title, full description, price
   - Special instructions text field (multiline, max 200 chars)
   - Quantity selector ([-] / [+] with min=1)
   - "Add to Cart" fixed bottom button
4. **Cart guard**: If the cart already has items from a different shop, a dialog prompts the user to "Start New" (clear cart) or "Cancel"
5. **On Add**: `CartNotifier.addOrUpdateItem()` creates/updates `CartItemModel`, persists to `shared_preferences`, pops back, and shows a SnackBar confirmation
6. **ViewCartBanner** appears globally with animated slide-up, showing item count + total + "View Cart" button
7. **"/my-cart"** route → `MyCartScreen` with full cart management

---

## 🎨 Theming

**Theme Config:** `packages/core/lib/theme/app_theme.dart`
**App Constants:** `packages/core/lib/constants/app_constants.dart`

All shop details widgets use:
- `AppColors.*` for colors (no hardcoded values)
- `AppDimens.*` for spacing, padding, border radius
- `Theme.of(context).textTheme.*` for typography

### Color Usage in Shop Details

| Purpose | Token |
|---------|-------|
| Price text | `AppColors.primary` (#FF6B35) |
| Add button icon | `AppColors.primary` (#FF6B35) |
| Rating stars | `AppColors.warning` (#FFA726) |
| Open badge bg | `AppColors.successLight` (#E8F5E9) |
| Closed badge bg | `AppColors.errorLight` (#FFEBEE) |
| Open badge text | `AppColors.success` (#4CAF50) |
| Closed badge text | `AppColors.error` (#D32F2F) |
| Secondary text | `AppColors.textSecondary` (#757575) |
| Hint text | `AppColors.textHint` (#9E9E9E) |
| Card border | `AppColors.surfaceVariant` 50% opacity |
| Surface/background | `AppColors.surface` (#F8F9FA) |
| Shimmer base | `AppColors.surfaceVariant` |
| Shimmer highlight | `AppColors.background` |

---

## ⚠️ Error Handling

### Result Pattern (in `packages/core/lib/errors/`)
```dart
// Success
Result<ShopModel>.success(shop);
Result<List<MenuItemModel>>.success(items);

// Failure
Result<ShopModel>.failure(ShopDetailsFailure.fetchShopFailed());
Result<List<MenuItemModel>>.failure(ShopDetailsFailure.fetchMenuFailed());
```

### ShopDetailsFailure Types (in `packages/core/lib/errors/failure.dart`)
```dart
ShopDetailsFailure.fetchShopFailed()    // Failed to load shop document
ShopDetailsFailure.fetchMenuFailed()    // Failed to load menu items
```

### Error Handling Strategy
- **Firestore exceptions:** Caught in `ShopDetailsDataSourceImpl`, mapped to `ShopDetailsFailure`
- **Repository-level catch:** `ShopDetailsRepositoryImpl` wraps all exceptions in `Result.failure`
- **UI handling:** `ShopDetailsNotifier` stores error in state
  - If **shop fetch fails**: Error state with retry button
  - If **menu fetch fails but shop succeeds**: Show shop info + empty menu (silent menu error)
  - `ShopDetailsErrorState` widget shows retry → calls `loadShopDetails()` again

---

## 🔒 Security Rules (Reference)

**File:** `firestore.rules` (root of repo)

In addition to the menu_items rules above, this feature relies on:
- `isAuthenticated()` function — checks `request.auth != null`
- `hasRole(role)` function — checks user document role field
- `isAdmin()` function — checks `hasRole('admin')`

---

## 📝 Conventions for Future Changes

### ✅ DO:
1. **Add new menu item fields** → update `MenuItemModel` Freezed model + `fromFirestore()` + `toFirestore()`
2. **Handle errors** using `Result<T>` pattern from `packages/core/`
3. **Use `AppColors`** and `AppDimens` from `packages/core/lib/constants/`
4. **Use `CachedNetworkImage`** for all remote images
5. **Use `ShopDetailsNotifier`** for all state changes (not direct Firestore calls in UI)
6. **Add matching skeleton** for any loading state changes
7. **Add security rules** when adding new collections
8. **Use `Flexible`/`Expanded`** inside Rows to prevent overflow
9. **Every `Text`** must have `maxLines` + `overflow: TextOverflow.ellipsis`

### ❌ DON'T:
1. Don't call Firestore directly from UI — go through providers
2. Don't hardcode colors/spacing — use theme constants
3. Don't skip error handling — always handle `Result.failure` cases
4. Don't use bare `!` operators on route parameters — use `??` with safe fallback
5. Don't forget to add composite indexes when adding compound Firestore queries

---

## 🔄 How to Modify This Feature

### Adding a New Menu Item Field
1. Add field to `MenuItemModel` Freezed in `data/models/menu_item_model.dart`
2. Update `fromFirestore()` and `toFirestore()` mappings
3. Run `build_runner` in `apps/user_app/`
4. Update this doc with new field
5. Update Firestore security rules if needed

### Adding Cart Integration to Add Button (✅ Done)
The cart feature is fully implemented. See `docs/cart_feature.md` for details.
1. `MenuItemCard.onAddTap` → `ShopDetailsScreen` pushes `/item-details` with `ItemDetailArgs`
2. `ItemDetailsScreen` → user selects quantity/instructions → taps "Add to Cart"
3. `CartNotifier.addOrUpdateItem()` persists to `shared_preferences`
4. `ViewCartBanner` slides up globally

### Adding a New Shop Detail Section (e.g., Reviews)
1. Add new widget in `presentation/widgets/`
2. Add it to the `CustomScrollView` in `ShopDetailsScreen`
3. Fetch data in `ShopDetailsNotifier.loadShopDetails()` if needed
4. Add skeleton placeholder in `ShopDetailsSkeleton`
5. Update this doc

---

## 🧪 Testing

### Current Tests
- None yet (feature is new)

### Future Tests Needed
- Unit tests for `MenuItemModel` (fromFirestore, toFirestore, formattedPrice)
- Unit tests for `ShopDetailsState.groupItems()` (correct grouping by category)
- Unit tests for `ShopDetailsNotifier` (mock repository)
- Widget tests for `MenuItemCard`, `ShopHeaderSection`
- Integration test for dashboard → shop details navigation

---

## 📦 Dependencies

All dependencies are already present in the user app:
- `cached_network_image: ^3.4.1` — Image caching
- `shimmer: ^3.0.0` — Skeleton loading
- `cloud_firestore` — Firestore database
- `flutter_riverpod` + `riverpod_annotation` — State management
- `freezed_annotation` + `json_annotation` — Code generation
- `go_router` — Navigation
- `fast_delivery_core` — Shared theme, errors, types

No new dependencies were added.

---

## 🚀 Quick Reference for AI Agents

**When modifying shop details feature, always:**
1. Read this file first (`docs/shop_details_feature.md`)
2. Follow Clean Architecture layers (data → domain → presentation)
3. Use `ShopDetailsNotifier` for all state changes (not direct Firestore calls in UI)
4. Handle errors with `Result<T>` pattern from `packages/core/lib/errors/`
5. Use `AppColors` and `AppDimens` from `packages/core/lib/constants/`
6. Update this doc after making changes
7. Run `flutter pub run build_runner build --delete-conflicting-outputs` in `apps/user_app/`
8. Run `flutter analyze` in `apps/user_app/` to catch issues

**Key Files to Review:**
- `apps/user_app/lib/features/shop_details/domain/providers/shop_details_providers.dart` — State management
- `apps/user_app/lib/features/shop_details/data/datasources/shop_details_datasource.dart` — Firestore queries
- `apps/user_app/lib/features/shop_details/data/models/menu_item_model.dart` — Menu item model
- `apps/user_app/lib/features/shop_details/presentation/pages/shop_details_screen.dart` — Main screen
- `apps/user_app/lib/features/shop_details/presentation/widgets/menu_item_card.dart` — Menu item card
- `apps/user_app/lib/main.dart` — Router configuration with `/shop/:shopId`
- `firestore.rules` — Security rules for menu_items subcollection
- `firestore.indexes.json` — Composite indexes
- `packages/core/lib/errors/failure.dart` — Failure types

**Common Pitfalls:**
- Forgetting `Flexible` in Row children (overflow errors)
- Forgetting `maxLines` + `overflow` on Text widgets
- Not running `build_runner` after adding/modifying Freezed models or providers
- Not adding composite indexes when adding compound Firestore queries
- Not updating security rules when adding new collections
- Hardcoding colors instead of using `AppColors`
- Using bare `!` on route parameters instead of safe `??` fallback

---

## 📌 Cross-Feature Integration Points

| Feature | Integration |
|---------|-------------|
| **Dashboard** | Shop card tap → `context.push('/shop/${shop.id}')` navigates to this screen. Shares `ShopModel` type. Both screens wrapped in ShellRoute with ViewCartBanner. |
| **Auth** | Auth gate protects `/shop/:shopId` route same as all other routes. Auth routes (`/login`, `/register`) are outside ShellRoute (no cart banner). |
| **Cart** | `MenuItemCard.onAddTap` → `ItemDetailsScreen` → `CartNotifier` → `ViewCartBanner` → `MyCartScreen`. Cart persisted via `shared_preferences`. |
| **Firestore** | Reads from `shops/{shopId}` document and `shops/{shopId}/menu_items/` subcollection |

---

### Completed ✓ — Breakdown by Route
| Route | Screen | Status |
|-------|--------|--------|
| `/` | `DashboardScreen` (inside ShellRoute) | ✅ Implemented |
| `/login` | `LoginScreen` (outside ShellRoute) | ✅ Implemented |
| `/register` | `RegisterScreen` (outside ShellRoute) | ✅ Implemented |
| `/shop/:shopId` | `ShopDetailsScreen` (inside ShellRoute) | ✅ Implemented |
| `/item-details` | `ItemDetailsScreen` (inside ShellRoute) | ✅ Implemented |
| `/my-cart` | `MyCartScreen` (inside ShellRoute) | ✅ Implemented |

---

**End of Shop Details Feature Specification**
