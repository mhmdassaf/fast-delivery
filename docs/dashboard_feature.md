# Dashboard Feature Specification

> **AI-Readable Documentation for Dashboard Feature**  
> **Last Updated:** 2026-05-15  
> **Feature Status:** ✅ Implemented  
> **Commit:** `HEAD` - feat(user_app): implement dashboard with shop listing, categories, search, and filters

---

## 📋 Feature Overview

**Purpose:** Main landing screen for the User App — shop discovery and browsing  
**Scope:** Shop listing, Category browsing, Search, Filtering, Pagination, Pull-to-refresh  
**Roles Supported:** `user`, `rider`, `seller`, `admin`  
**Platform:** Flutter (iOS, Android, Web)  
**Architecture:** App-local feature (uses shared `fast_delivery_core` package)

---

## 📦 Feature Structure

The dashboard is an **app-local feature** (not a shared package) since it's specific to the User App:

```
apps/user_app/lib/features/dashboard/
├── data/
│   ├── datasources/
│   │   └── dashboard_datasource.dart        # Firebase Firestore operations
│   ├── models/
│   │   ├── category_model.dart              # Freezed model for categories
│   │   ├── category_model.freezed.dart
│   │   ├── category_model.g.dart
│   │   ├── shop_model.dart                  # Freezed model for shops
│   │   ├── shop_model.freezed.dart
│   │   ├── shop_model.g.dart
│   │   ├── shop_filter_model.dart           # Freezed model for filtering/sorting
│   │   ├── shop_filter_model.freezed.dart
│   │   └── shop_filter_model.g.dart
│   └── repositories/
│       └── dashboard_repository.dart        # Repository interface + impl
├── domain/
│   └── providers/
│       ├── dashboard_providers.dart         # Riverpod providers + DashboardNotifier
│       └── dashboard_providers.g.dart       # Generated code
└── presentation/
    ├── pages/
    │   └── dashboard_screen.dart            # Main dashboard screen
    └── widgets/
        ├── categories_bar.dart              # Horizontal category chips
        ├── dashboard_app_bar.dart           # Greeting, location, notifications
        ├── dashboard_empty_state.dart       # Empty state illustration
        ├── dashboard_error_state.dart       # Error state with retry
        ├── filter_bottom_sheet.dart         # Modal filter bottom sheet
        ├── search_bar_widget.dart           # Debounced search input
        ├── shop_card.dart                   # Shop card with image + details
        ├── shop_card_skeleton.dart          # Shimmer loading skeleton
        └── shop_list.dart                  # Paginated single-column list
```

### Package Dependencies:
- **fast_delivery_core** — Used for `AppColors`, `AppDimens`, `Failure`/`Result` types
- **fast_delivery_auth** — Used for `AuthNotifier`, `authStatusProvider`, `currentUserProvider`
- No other shared packages needed (dashboard is app-local)

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure (in `apps/user_app/lib/features/dashboard/`)

The dashboard follows Clean Architecture within the User App:

```
apps/user_app/lib/features/dashboard/
├── data/
│   ├── datasources/
│   │   └── dashboard_datasource.dart       # Firestore queries for shops + categories
│   ├── models/
│   │   ├── category_model.dart             # Freezed model with fromFirestore()
│   │   ├── shop_model.dart                 # Freezed model with fromFirestore()
│   │   └── shop_filter_model.dart          # Freezed model for filter state
│   └── repositories/
│       └── dashboard_repository.dart       # Repository interface + Firestore impl
├── domain/
│   └── providers/
│       ├── dashboard_providers.dart        # Riverpod providers + DashboardNotifier
│       └── dashboard_providers.g.dart
└── presentation/
    ├── pages/
    │   └── dashboard_screen.dart           # Main scrollable dashboard
    └── widgets/
        ├── categories_bar.dart             # Category filter bar
        ├── dashboard_app_bar.dart          # Top app bar
        ├── dashboard_empty_state.dart      # Empty state
        ├── dashboard_error_state.dart      # Error state
        ├── filter_bottom_sheet.dart        # Filter modal
        ├── search_bar_widget.dart          # Search input
        ├── shop_card.dart                  # Shop card
        ├── shop_card_skeleton.dart         # Shimmer loading
        └── shop_list.dart                 # Paginated listing
```

### Key Principles
- **Data Layer:** Handles Firestore queries for shops and categories via `DashboardDataSourceImpl`
- **Domain Layer:** Contains business logic via Riverpod `DashboardNotifier` — handles state, pagination, filtering, search debouncing
- **Presentation Layer:** Composable widgets that consume providers via `ConsumerWidget`/`ConsumerStatefulWidget`
- **Core Layer:** Shared utilities from `packages/core/` (theme, errors, result pattern)

### Data Flow
```
User Action → Widget → DashboardNotifier → DashboardRepository → DashboardDataSource → Firestore
                                                                                              ↓
User sees UI ← Widget rebuild ← State update ← DashboardNotifier ← DashboardRepository ← Result<T>
```

---

## 📊 State Management (Riverpod)

### Providers (in `domain/providers/dashboard_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `firebaseFirestoreProvider` | `@riverpod` (AutoDispose) | Exposes `FirebaseFirestore.instance` |
| `dashboardDataSourceProvider` | `@riverpod` (AutoDispose) | Creates `DashboardDataSourceImpl` |
| `dashboardRepositoryProvider` | `@riverpod` (AutoDispose) | Creates `DashboardRepositoryImpl` |
| `dashboardNotifierProvider` | `@riverpod` (Notifier) | **Main state manager** — `DashboardNotifier` class |

### DashboardNotifier State
```dart
class DashboardState {
  final List<ShopModel> shops;              // Loaded shops
  final List<CategoryModel> categories;      // Loaded categories
  final String? selectedCategoryId;          // Selected category (null = All)
  final String searchQuery;                  // Current search string
  final bool isLoading;                      // Initial loading
  final bool isLoadingMore;                  // Pagination loading
  final bool isRefreshing;                   // Pull-to-refresh
  final String? errorMessage;                // Error state
  final DocumentSnapshot<Object?>? lastDocument; // Pagination cursor
  final bool hasMoreData;                    // More pages available
  final ShopFilterModel filter;              // Active filter settings
}
```

### DashboardNotifier Methods

| Method | Purpose |
|--------|---------|
| `loadInitialData()` | Load categories + first page of shops |
| `loadMoreShops()` | Paginate — load next page |
| `refresh()` | Pull-to-refresh — reload all data |
| `selectCategory(String?)` | Filter by category (null = All) |
| `onSearchChanged(String)` | Debounced search input |
| `clearSearch()` | Reset search and reload |
| `updateFilter(ShopFilterModel)` | Apply new filter and reload |
| `clearFilters()` | Reset to default filter |
| `toggleOpenNow()` | Toggle open-now filter |
| `removeRatingFilter()` | Remove min-rating filter |
| `removeDeliveryFeeFilter()` | Remove max-delivery-fee filter |
| `clearError()` | Dismiss error message |

### Internal Helpers (reduces duplication)

| Helper | Purpose |
|--------|---------|
| `_handleCategoriesResult(Result)` | Updates state with categories or error |
| `_handleShopsResult(Result, {append})` | Updates state with shops, cursor, hasMore |

---

## 🧭 Navigation (GoRouter)

**Router Config:** Defined in `apps/user_app/lib/main.dart` via `routerProvider`

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authStatusProvider);
  // ... redirect logic based on auth status
});
```

### Auth Redirect Logic
```
/authStatus == authenticated → free navigation
  /authStatus == initial → stay (splash/loading)
  /authStatus == unauthenticated → redirect to /login
  /authenticated user on /login or /register → redirect to /
```

### Routes

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | `DashboardScreen` | Main dashboard — shop listing |
| `/login` | `LoginScreen` (from auth package) | Email/password login |
| `/register` | `RegisterScreen` (from auth package) | New user registration |
| `/shop/:shopId` | `_ShopDetailsPlaceholder` | Shop details (placeholder — future feature) |

### Navigation Usage (in widgets)
```dart
// Navigate to shop details
context.push('/shop/${shop.id}');

// Navigate to auth pages
context.go('/login');
```

---

## 🔥 Firebase Integration

### Firestore Collections Used

#### `categories/{categoryId}`

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Category display name (e.g. "Pizza", "Burger") |
| `icon` | String | Icon name for UI mapping (`restaurant`, `bakery`, etc.) |
| `imageUrl` | String? | Optional category image |
| `order` | Number | Display sort order (ascending) |
| `isActive` | Boolean | Soft-delete flag |
| `createdAt` | Timestamp | Creation time |
| `updatedAt` | Timestamp | Last update |

#### `shops/{shopId}`

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Shop display name |
| `categoryId` | String | Reference to `categories/{id}` |
| `shortDescription` | String? | Brief tagline/description |
| `tags` | List\<String\> | Searchable tags (e.g. `["pizza", "italian"]`) |
| `logoUrl` | String | Shop logo/cover image URL |
| `coverImageUrl` | String? | Optional cover image |
| `rating` | Number | Average rating (0.0–5.0) |
| `ratingCount` | Number | Number of ratings |
| `deliveryTime` | String | Estimated delivery time (e.g. "25-35 min") |
| `deliveryFee` | Number | Delivery fee in dollars |
| `minOrderAmount` | Number | Minimum order amount |
| `isOpen` | Boolean | Currently open for orders |
| `isAddress` | String? | Physical address |
| `latitude` | Number? | Location latitude (for distance sorting) |
| `longitude` | Number? | Location longitude |
| `isActive` | Boolean | Soft-delete flag |
| `createdAt` | Timestamp | Creation time |
| `updatedAt` | Timestamp | Last update |

### Data Source Methods (in `dashboard_datasource.dart`)

| Method | Purpose |
|--------|---------|
| `getCategories()` | Fetch active categories sorted by `order` |
| `getShops({categoryId, filter, searchQuery, lastDocument, pageSize})` | Paginated shop queries with filters |

### Query Strategy (Hybrid: Server equality + Client range)

To minimize composite index requirements while supporting rich filtering:

1. **Server-side (Firestore):** Equality filters only
   - `isActive == true` (always applied)
   - `categoryId == X` (when category selected)
   - `isOpen == true` (when open-now filter active)
   - Always ordered by `createdAt DESC` for consistent cursor pagination

2. **Client-side (Dart):** Range filters + sorting + search
   - `minRating` — filtered after fetch
   - `maxDeliveryFee` — filtered after fetch
   - `sortBy` — sorted after fetch (rating, delivery fee, distance, newest)
   - `searchQuery` — matched against `name`, `tags`, `shortDescription`

This requires only **4 composite indexes** (far fewer than alternatives):

| Index | Fields |
|-------|--------|
| 1 | `isActive ASC`, `createdAt DESC` |
| 2 | `isActive ASC`, `categoryId ASC`, `createdAt DESC` |
| 3 | `isActive ASC`, `isOpen ASC`, `createdAt DESC` |
| 4 | `isActive ASC`, `categoryId ASC`, `isOpen ASC`, `createdAt DESC` |

### Security Rules (in `firestore.rules`)

**Shops Collection:**
```javascript
match /shops/{shopId} {
  allow read: if isAuthenticated();                              // All authenticated users
  allow create: if hasRole('seller') && sellerId == auth.uid;    // Shop owners only
  allow update: if hasRole('seller') && sellerId == auth.uid;    // Shop owners only
  allow read, write: if isAdmin();                               // Admins can do everything
  allow delete: if false;                                        // Soft-delete via isActive
}
```

**Categories Collection:**
```javascript
match /categories/{categoryId} {
  allow read: if isAuthenticated();   // All authenticated users
  allow write: if isAdmin();          // Admins only
  allow delete: if false;             // Soft-delete via isActive
}
```

---

## 🎨 UI Components

### Dashboard Screen Structure (vertical scroll)
```
┌──────────────────────────────────┐
│ DashboardAppBar                  │  ← Greeting + location + notifications + avatar
├──────────────────────────────────┤
│ SearchBarWidget     [Filter] btn │  ← Debounced search + filter toggle
├──────────────────────────────────┤
│ CategoriesBar                     │  ← Horizontal category chips (scrollable)
├──────────────────────────────────┤
│ [Active Filter Chips]            │  ← Shown when filters active (conditional)
├──────────────────────────────────┤
│ "All Shops"          12 shops    │  ← Section header with count
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │ ShopCard                     │ │  ← Image + name + status + rating + delivery info
│ ├──────────────────────────────┤ │
│ │ ShopCard                     │ │
│ ├──────────────────────────────┤ │
│ │ ShopCard                     │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ [Loading indicator]              │  ← Shown during pagination
└──────────────────────────────────┘
```

### Widgets Catalog

| Widget | Purpose | Key Features |
|--------|---------|--------------|
| `DashboardAppBar` | Top app bar | Time-based greeting, user name, location picker, notification bell with badge, profile avatar |
| `SearchBarWidget` | Search input | Debounced input, clear button, custom hint, filled style with rounded border |
| `CategoriesBar` | Category filter | Horizontal scrollable chips, "All" always first, shimmer loading, icon mapping from name |
| `FilterBottomSheet` | Filter modal | Sort by (rating/delivery fee/distance/newest), open-now toggle, rating slider, delivery fee slider, reset/apply buttons |
| `ShopList` | Shop listing | Single-column `ListView.builder` with `shrinkWrap: true`, `NotificationListener` for pagination, 5-skeleton initial load |
| `ShopCard` | Shop card | 16:9 cover image via `CachedNetworkImage`, open/closed badge, rating + count, delivery time + fee |
| `ShopCardSkeleton` | Loading skeleton | `Shimmer` animation matching `ShopCard` layout exactly |
| `DashboardEmptyState` | Empty state | Contextual message (no shops / no search results), clear search/filter buttons |
| `DashboardErrorState` | Error state | Error icon, message, retry button |

### Overflow Prevention (per `SKILL.md`)
All card layouts follow the overflow-prevention skill:
- Every `Text` has `maxLines: 1` + `TextOverflow.ellipsis`
- Single-column list gives cards ~400dp+ width (no horizontal overflow)
- `Flexible` and `Expanded` used inside content rows
- `Spacer` is not relied on to prevent overflow

### Formatted Values
- **Delivery Fee:** `0.0` → "Free", otherwise `$3.99`
- **Rating:** `4.5` → "4.5 (234)"
- **Delivery Time:** Raw string from Firestore (e.g. "25-35 min")

---

## 🎨 Theming

**Theme Config:** `packages/core/lib/theme/app_theme.dart`
**App Constants:** `packages/core/lib/constants/app_constants.dart`

All dashboard widgets use:
- `AppColors.*` for colors (no hardcoded values)
- `AppDimens.*` for spacing, padding, border radius
- `Theme.of(context).textTheme.*` for typography

### Color Usage in Dashboard
| Purpose | Token |
|---------|-------|
| Primary action color | `AppColors.primary` (#FF6B35) |
| Background | `AppColors.background` (white) |
| Surface | `AppColors.surface` (#F8F9FA) |
| Text primary | `AppColors.onBackground` (#212121) |
| Text secondary | `AppColors.textSecondary` (#757575) |
| Success/Open | `AppColors.success` / `AppColors.successLight` |
| Error/Closed | `AppColors.error` / `AppColors.errorLight` |
| Rating stars | `AppColors.warning` (#FFA726) |

---

## ⚠️ Error Handling

### Result Pattern (in `packages/core/lib/errors/`)
```dart
// Success
Result<List<CategoryModel>>.success(categories);

// Failure
Result<List<CategoryModel>>.failure(DashboardFailure.fetchCategoriesFailed());
```

### DashboardFailure Types (in `packages/core/lib/errors/failure.dart`)
```dart
DashboardFailure.fetchFailed()          // Failed to load shops
DashboardFailure.fetchCategoriesFailed() // Failed to load categories
```

### Error Handling Strategy
- **Firestore exceptions:** Caught in `DashboardDataSourceImpl`, mapped to `DashboardFailure`
- **Missing index errors:** Special handling with helpful message about Firebase console
- **Repository-level catch:** `DashboardRepositoryImpl` wraps all exceptions in `Result.failure`
- **UI handling:** `DashboardNotifier` stores error in state → `DashboardErrorState` widget shows retry button

---

## 🔒 Security Rules (Reference)

**File:** `firestore.rules` (root of repo)

In addition to the shops and categories rules above, the dashboard relies on:
- `isAuthenticated()` function — checks `request.auth != null`
- `hasRole(role)` function — checks `get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role`
- `isAdmin()` function — checks `hasRole('admin')`

---

## 📝 Conventions for Future Changes

### ✅ DO:
1. **Add new providers** using `@riverpod` annotation → run `build_runner` in `apps/user_app/`
2. **Add new data** to models → update Freezed model + `fromFirestore()` + `toFirestore()`
3. **Handle errors** using `Result<T>` pattern from `packages/core/`
4. **Use `AppColors`** and `AppDimens` from `packages/core/lib/constants/`
5. **Use `NotificationsListener`** for scroll-based pagination (not duplicate scroll listeners)
6. **Add new widgets** in `presentation/widgets/`
7. **Add matching skeletons** for any loading state
8. **Use `CachedNetworkImage`** for all remote images
9. **Add composite indexes** to `firestore.indexes.json` when adding compound queries
10. **Add security rules** to `firestore.rules` when adding new collections

### ❌ DON'T:
1. **Don't put business logic in UI** — use `DashboardNotifier`
2. **Don't call Firestore directly from UI** — go through providers
3. **Don't hardcode colors/spacing** — use theme constants
4. **Don't forget to dispose** `TextEditingController` in `State.dispose()`
5. **Don't duplicate pagination listeners** — only `ShopList`'s `NotificationListener` triggers `loadMoreShops()`
6. **Don't skip error handling** — always handle `Result.failure` cases
7. **Don't use bare `!` operators** on route parameters — use `??` with safe fallback
8. **Don't commit temp tokens** like `tmp_token.txt` — ensure added to `.gitignore`

---

## 🔄 How to Modify This Feature

### Adding a New Filter Option
1. Add field to `ShopFilterModel` (Freezed) in `data/models/shop_filter_model.dart`
2. Add client-side filter logic in `DashboardDataSourceImpl.getShops()`
3. Add filter UI in `FilterBottomSheet` in `presentation/widgets/filter_bottom_sheet.dart`
4. Add active filter chip in `DashboardScreen._ActiveFilterChips` if needed
5. Add remove method in `DashboardNotifier` if needed
6. Run `build_runner` in `apps/user_app/`
7. **Update this doc** with new filter

### Adding a New Sorting Option
1. Add value to `SortOption` enum in `shop_filter_model.dart`
2. Add sort case in `DashboardDataSourceImpl.getShops()`
3. Add chip label in `FilterBottomSheet._SortSelector`
4. Run `build_runner` in `apps/user_app/`
5. **Update this doc** with new sort

### Adding a New Screen (e.g., Shop Details)
1. Create screen in `presentation/pages/` or `presentation/widgets/`
2. Add route to `routerProvider` in `apps/user_app/lib/main.dart`
3. Replace `_ShopDetailsPlaceholder` with the real screen
4. **Update this doc** with new route

### Changing Shop/Category Model
1. Update Freezed model in `data/models/shop_model.dart` or `category_model.dart`
2. Update `fromFirestore()` and `toFirestore()` mappings
3. Run `build_runner` in `apps/user_app/`
4. Update Firestore security rules if needed
5. Update seed scripts if needed
6. **Update this doc** with new fields

---

## 🧪 Testing

### Current Tests (in `apps/user_app/test/widget_test.dart`)
- `FastDeliveryApp can be instantiated without throwing` — Verifies app widget creation
- `FastDeliveryApp is a ConsumerWidget` — Verifies widget type (requires Riverpod `ProviderScope`)

### Future Tests Needed
- Unit tests for `DashboardNotifier` (mock repository)
- Unit tests for `ShopFilterModel` (filter combinations)
- Unit tests for `DashboardDataSourceImpl` (mock Firestore)
- Widget tests for `ShopCard`, `CategoriesBar`, `SearchBarWidget`
- Integration tests for dashboard → shop details flow
- Scroll/pagination behavior tests

---

## 📦 Dependencies (Added for Dashboard)

### User App (`apps/user_app/pubspec.yaml`) — New Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `cached_network_image` | ^3.4.1 | Image caching for shop cards |
| `shimmer` | ^3.0.0 | Skeleton loading animations |

### Existing Dependencies (used by dashboard)
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod code gen |
| `freezed_annotation` | ^3.0.0 | Immutable models |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `cloud_firestore` | ^5.6.7 | Firestore database |
| `go_router` | ^14.8.1 | Navigation |

---

## 🚀 Quick Reference for AI Agents

**When modifying dashboard feature, always:**
1. Read this file first (`docs/dashboard_feature.md`)
2. Follow Clean Architecture layers (data → domain → presentation)
3. Use `DashboardNotifier` for all state changes (not direct Firestore calls in UI)
4. Handle errors with `Result<T>` pattern from `packages/core/lib/errors/`
5. Use `AppColors` and `AppDimens` from `packages/core/lib/constants/`
6. Update this doc after making changes
7. Run `flutter pub run build_runner build --delete-conflicting-outputs` in `apps/user_app/`
8. Run `flutter test --concurrency=8` in `apps/user_app/`

**Key Files to Review:**
- `apps/user_app/lib/features/dashboard/domain/providers/dashboard_providers.dart` — State management
- `apps/user_app/lib/features/dashboard/data/datasources/dashboard_datasource.dart` — Firestore queries
- `apps/user_app/lib/features/dashboard/presentation/pages/dashboard_screen.dart` — Main screen
- `apps/user_app/lib/main.dart` — Router configuration
- `firestore.rules` — Security rules
- `firestore.indexes.json` — Composite indexes
- `packages/core/lib/errors/failure.dart` — Failure types

**Common Pitfalls:**
- Duplicate pagination scroll listeners (screen + ShopList both listening)
- Forgetting to run `build_runner` after adding/modifying Freezed models or providers
- Not adding composite indexes when adding compound Firestore queries
- Not updating security rules when adding new collections
- Hardcoding colors instead of using `AppColors`
- Using bare `!` on route parameters instead of safe `??` fallback
- Committing temporary auth tokens (`tmp_token.txt`)

---

## 📦 Related Firestore Infrastructure

### Composite Indexes (in `firestore.indexes.json`)
Dashboard queries require these indexes to avoid `FAILED_PRECONDITION` errors:

```json
[
  {"collectionGroup": "categories", "queryScope": "COLLECTION", "fields": [
    {"fieldPath": "isActive", "order": "ascending"},
    {"fieldPath": "order", "order": "ascending"}
  ]},
  {"collectionGroup": "shops", "queryScope": "COLLECTION", "fields": [
    {"fieldPath": "isActive", "order": "ascending"},
    {"fieldPath": "createdAt", "order": "descending"}
  ]},
  {"collectionGroup": "shops", "queryScope": "COLLECTION", "fields": [
    {"fieldPath": "isActive", "order": "ascending"},
    {"fieldPath": "categoryId", "order": "ascending"},
    {"fieldPath": "createdAt", "order": "descending"}
  ]},
  {"collectionGroup": "shops", "queryScope": "COLLECTION", "fields": [
    {"fieldPath": "isActive", "order": "ascending"},
    {"fieldPath": "isOpen", "order": "ascending"},
    {"fieldPath": "createdAt", "order": "descending"}
  ]},
  {"collectionGroup": "shops", "queryScope": "COLLECTION", "fields": [
    {"fieldPath": "isActive", "order": "ascending"},
    {"fieldPath": "categoryId", "order": "ascending"},
    {"fieldPath": "isOpen", "order": "ascending"},
    {"fieldPath": "createdAt", "order": "descending"}
  ]}
]
```

### Deployment Scripts (in `functions/`)
- `deploy_dev_rules.js` — Deploys permissive `request.auth != null` rules (for seeding)
- `deploy_real_rules.js` — Deploys strict rules from `firestore.rules`
- `create_indexes.js` — Creates composite indexes via REST API
- `check_indexes.js` — Lists existing indexes and their states
- `seed_firestore.mjs` — Seeds categories + shops data (uses Admin SDK)
- `seed_via_user.mjs` — Alternative seed via custom auth token + REST API

---

## 📌 Cross-Feature Integration Points

| Feature | Integration |
|---------|-------------|
| **Auth** | `authStatusProvider` drives router redirect; `currentUserProvider` provides user name/photo for `DashboardAppBar` |
| **Notifications** | `DashboardAppBar` notification bell ready for FCM integration (placeholder `onNotificationTap`) |
| **Shop Details** | Route `/shop/:shopId` registered in router with `_ShopDetailsPlaceholder` — ready for future implementation |
| **Firestore** | `DashboardDataSourceImpl` reads from `categories` and `shops` collections |

---

**End of Dashboard Feature Specification**
