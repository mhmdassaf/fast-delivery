# Shop Details & Menu Feature Specification

> **AI-Readable Documentation for Shop Details & Menu Feature**  
> **Last Updated:** 2026-05-18  
> **Feature Status:** ✅ Implemented (pending commit)  
> **Commit:** *(pending — will be committed after review)*

---

## 📋 Feature Overview

**Purpose:** Display shop details and menu when a user taps a shop card on the dashboard  
**Scope:** Shop info (cover, logo, rating, delivery), menu items organized by category, add-to-cart placeholder  
**Roles Supported:** `user`, `rider`, `seller`, `admin`  
**Platform:** Flutter (iOS, Android, Web)  
**Architecture:** App-local feature (uses shared `fast_delivery_core` package)

---

## 📦 Feature Structure

```
apps/user_app/lib/features/shop_details/
├── data/
│   ├── datasources/
│   │   └── shop_details_datasource.dart        # Firestore operations for shop + menu
│   ├── models/
│   │   ├── menu_item_group.dart                # Simple helper class for grouped items
│   │   ├── menu_item_model.dart                # Freezed model for menu items
│   │   ├── menu_item_model.freezed.dart
│   │   └── menu_item_model.g.dart
│   └── repositories/
│       └── shop_details_repository.dart        # Repository interface + impl
├── domain/
│   └── providers/
│       ├── shop_details_providers.dart          # Riverpod providers + ShopDetailsNotifier
│       └── shop_details_providers.g.dart        # Generated code
└── presentation/
    ├── pages/
    │   └── shop_details_screen.dart            # Main shop details screen
    └── widgets/
        ├── menu_category_section.dart          # Category header + item list
        ├── menu_item_card.dart                 # Individual menu item card
        ├── shop_details_error_state.dart       # Error state with retry
        ├── shop_details_skeleton.dart          # Shimmer loading skeleton
        └── shop_header_section.dart            # Cover image, logo, name, rating, delivery
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

```dart
// Shop details route
GoRoute(
  path: '/shop/:shopId',
  builder: (context, state) {
    final shopId = state.pathParameters['shopId'] ?? '';
    return ShopDetailsScreen(shopId: shopId);
  },
),
```

Navigation from dashboard shop card:
```dart
context.push('/shop/${shop.id}');
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
| `MenuItemCard` | Individual menu item | 80×80 image left, title (1 line), description (2 lines), price USD, add icon button (SnackBar placeholder) |
| `MenuCategorySection` | Category grouping | Bold category name with divider line + item count, list of MenuItemCards |
| `ShopDetailsSkeleton` | Loading skeleton | Shimmer matching full layout: cover, logo, name, rating, category sections with card placeholders |
| `ShopDetailsErrorState` | Error display | Error icon, title, message, "Try Again" button |
| `_EmptyMenuState` | No menu state (private) | "Menu coming soon" with restaurant icon, hint text; defined inside `shop_details_screen.dart` |

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

### Add Button Behavior
The [+] button on `MenuItemCard` is a **visual placeholder**:
- Displays a floating SnackBar: `"{item name} added to cart"`
- Calls `onAddTap` callback if provided (for future extensibility)
- Actual cart storage will be implemented in a separate "Cart" feature

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
6. Don't remove the SnackBar placeholder from the add button until cart feature is implemented

---

## 🔄 How to Modify This Feature

### Adding a New Menu Item Field
1. Add field to `MenuItemModel` Freezed in `data/models/menu_item_model.dart`
2. Update `fromFirestore()` and `toFirestore()` mappings
3. Run `build_runner` in `apps/user_app/`
4. Update this doc with new field
5. Update Firestore security rules if needed

### Adding Cart Integration to Add Button
1. Create cart feature (future)
2. Update `MenuItemCard.onAddTap` callback or replace with actual cart provider call
3. Remove SnackBar placeholder behavior
4. Update this doc

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
| **Dashboard** | Shop card tap → `context.push('/shop/${shop.id}')` navigates to this screen. Shares `ShopModel` type. |
| **Auth** | Auth gate protects `/shop/:shopId` route same as all other routes |
| **Cart** (future) | Add button `onAddTap` callback ready for cart provider injection |
| **Firestore** | Reads from `shops/{shopId}` document and `shops/{shopId}/menu_items/` subcollection |

---

### Completed ✓ — Breakdown by Route
| Route | Screen | Status |
|-------|--------|--------|
| `/` | `DashboardScreen` | ✅ Implemented |
| `/login` | `LoginScreen` | ✅ Implemented |
| `/register` | `RegisterScreen` | ✅ Implemented |
| `/shop/:shopId` | `ShopDetailsScreen` | ✅ Implemented (was placeholder) |

---

**End of Shop Details Feature Specification**
