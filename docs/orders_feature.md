# Orders List Feature Specification

> **AI-Readable Documentation for Orders List Feature**  
> **Last Updated:** 2026-05-24  
> **Feature Status:** ✅ Implemented

---

## 📋 Feature Overview

**Purpose:** Shared orders list screen visible across all Fast Delivery apps  
**Scope:** Role-based order listing, status filtering, pagination, pull-to-refresh  
**Roles Supported:** `user`, `rider`, `seller`, `admin`  
**Platform:** Flutter (iOS, Android, Web)  
**Architecture:** Shared package (`packages/orders/`)

---

## 📦 Package Structure

```
packages/orders/
├── pubspec.yaml                                  # fast_delivery_orders
└── lib/
    ├── data/
    │   ├── datasources/
    │   │   └── order_list_datasource.dart         # Role-based Firestore queries
    │   ├── models/
    │   │   ├── order_list_item_model.dart          # Freezed — lightweight list model
    │   │   ├── order_list_item_model.freezed.dart  # Generated
    │   │   └── order_list_item_model.g.dart        # Generated
    │   └── repositories/
    │       └── order_list_repository.dart          # Wraps datasource
    ├── domain/
    │   ├── order_list_providers.dart               # OrderListNotifier + infrastructure providers
    │   └── order_list_providers.g.dart             # Generated
    └── presentation/
        ├── pages/
        │   └── orders_list_screen.dart             # Main orders list screen
        └── widgets/
            ├── order_card.dart                     # Order card: shop, address, status, items, total
            ├── order_status_badge.dart             # Colored status chip
            ├── order_status_filter_bar.dart        # Horizontal filter chips (All/Active/Completed/Cancelled)
            ├── order_list_loading.dart             # Shimmer skeleton
            └── order_list_empty_state.dart         # Empty state with context
```

### Package Dependencies:
- **fast_delivery_core** — Used for `AppColors`, `AppDimens`, `Failure`/`Result` types
- **fast_delivery_auth** — Used for `currentUserProvider` (user role + uid)
- External: `cloud_firestore`, `flutter_riverpod`, `riverpod_annotation`, `freezed_annotation`, `intl`, `shimmer`

### Apps Using This Package:
```
apps/user_app/       → uses fast_delivery_orders → /orders route
apps/rider_app/      → uses fast_delivery_orders → /orders route
apps/seller_app/     → uses fast_delivery_orders → /orders route
apps/admin_panel/    → uses fast_delivery_orders → /orders route
```

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure (in `packages/orders/lib/`)

```
lib/
├── data/                         # Data layer
│   ├── datasources/              # Firestore role-based queries
│   ├── models/                    # Freezed models
│   └── repositories/             # Repository wrapper
├── domain/                       # Domain layer
│   └── order_list_providers.dart  # OrderListNotifier + infrastructure providers
└── presentation/                 # Presentation layer
    ├── pages/                    # OrdersListScreen
    └── widgets/                  # Reusable order list widgets
```

### Key Principles
- **Data Layer:** Role-aware Firestore queries based on `userId`, `riderId`, `sellerId`, or no filter for admin
- **Domain Layer:** `OrderListNotifier` manages state, pagination, status filtering, pull-to-refresh
- **Presentation Layer:** `ConsumerStatefulWidget` with scroll listener for pagination
- **Shared Package:** Single source of truth used by all 4 apps

### Data Flow
```
User Action → Widget → OrderListNotifier → OrderListRepository → OrderListDataSource → Firestore
                                                                                          ↓
User sees UI ← Widget rebuild ← State update ← OrderListNotifier ← OrderListRepository ← OrdersQueryResult
```

---

## 🔥 Role-Based Query Strategy

| Role | Firestore Filter | Source |
|------|-----------------|--------|
| `user` | `.where('userId', isEqualTo: uid)` | Current user's own orders |
| `rider` | `.where('riderId', isEqualTo: uid)` | Orders assigned to rider |
| `seller` | `.where('sellerId', isEqualTo: uid)` | Orders for seller's shop |
| `admin` | No filter (all orders) | Full access |

The role is derived from `currentUserProvider` → `user?.role.name`.

---

## 📊 State Management (Riverpod)

### Providers (in `domain/order_list_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `ordersFirestoreProvider` | `@riverpod` | Exposes `FirebaseFirestore.instance` |
| `ordersDataSourceProvider` | `@riverpod` | Creates `OrderListDataSourceImpl` |
| `ordersRepositoryProvider` | `@riverpod` | Creates `OrderListRepositoryImpl` |
| `orderListNotifierProvider` | `@riverpod` Notifier | **Main state manager** — `OrderListNotifier` |

### OrderListState Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `orders` | `List<OrderListItemModel>` | `[]` | Loaded orders |
| `selectedStatusFilter` | `String?` | `null` | Current status filter (null = "All") |
| `isLoading` | `bool` | `false` | Initial loading |
| `isLoadingMore` | `bool` | `false` | Pagination loading |
| `isRefreshing` | `bool` | `false` | Pull-to-refresh |
| `errorMessage` | `String?` | `null` | Error state |
| `lastDocument` | `DocumentSnapshot?` | `null` | Pagination cursor |
| `hasMoreData` | `bool` | `true` | More pages available |

### OrderListNotifier Methods

| Method | Purpose |
|--------|---------|
| `loadInitialData()` | Reload from scratch |
| `loadMoreOrders()` | Paginate — load next page |
| `refresh()` | Pull-to-refresh |
| `setStatusFilter(String?)` | Filter by status group (null = "All") |
| `clearError()` | Dismiss error |

### StatusFilterOption Enum

| Value | Label | Filter Value | Included Statuses |
|-------|-------|-------------|-------------------|
| `all` | "All" | `null` | All statuses |
| `active` | "Active" | `'Active'` | Waiting Rider Confirmation, Confirmed, Preparing, Out for Delivery |
| `completed` | "Completed" | `'Completed'` | Delivered |
| `cancelled` | "Cancelled" | `'Cancelled'` | Cancelled |

---

## 🧭 Navigation (GoRouter)

### Routes Added Per App

All apps use `StatefulShellRoute.indexedStack` (via `MainShell`) with 3 branches:

| App | Tab | Route | Screen |
|-----|-----|-------|--------|
| **user_app** | Home | `/` | `DashboardScreen` |
| **user_app** | Orders | `/orders` | `OrdersListScreen` |
| **rider_app** | Home | `/` | `RiderDashboardScreen` |
| **rider_app** | Orders | `/orders` | `OrdersListScreen` |
| **seller_app** | Home | `/` | `SellerDashboardScreen` |
| **seller_app** | Orders | `/orders` | `OrdersListScreen` |
| **admin_panel** | Home | `/` | `AdminDashboardScreen` |
| **admin_panel** | Orders | `/orders` | `OrdersListScreen` |
| **All apps** | Account | `/account` | Placeholder (no-op) |
| **All apps** | — | `/login` | `LoginScreen` (outside shell) |
| **All apps** | — | `/register` | `RegisterScreen` (outside shell) |

### Auth Redirect Logic

Each app has a `routerProvider` with redirect logic:
- Unauthenticated → `/login`
- Authenticated on `/login` or `/register` → `/`
- Authenticated → free navigation

---

## 🎨 UI Components

### OrdersListScreen Layout
```
┌──────────────────────────────────┐
│ AppBar: "My Orders"              │
├──────────────────────────────────┤
│ StatusFilterBar: All | Active |   │
│   Completed | Cancelled           │
├──────────────────────────────────┤
│ ┌──────────────────────────────┐ │
│ │ OrderCard                    │ │  ← Shop name, address, items, total, status, time
│ ├──────────────────────────────┤ │
│ │ OrderCard                    │ │
│ └──────────────────────────────┘ │
├──────────────────────────────────┤
│ [Loading indicator]              │  ← During pagination
└──────────────────────────────────┘
```

### Widgets Catalog

| Widget | Purpose | Key Features |
|--------|---------|--------------|
| `OrdersListScreen` | Main screen | Pull-to-refresh, pagination via scroll listener, loading/error/empty states |
| `OrderCard` | Order list item | Shop name, delivery address, item count, total price, status badge, relative time |
| `OrderStatusBadge` | Status indicator | Color-coded: Amber=Active, Green=Delivered, Red=Cancelled |
| `OrderStatusFilterBar` | Filter chips | Horizontal scrollable, `FilterChip` with selected state |
| `OrderListLoading` | Skeleton | 4 shimmer cards matching `OrderCard` layout |
| `OrderListEmptyState` | Empty state | Context-specific message (no orders vs no matching filters) |

### Dashboard Screens

| Screen | Icon | Button |
|--------|------|--------|
| `RiderDashboardScreen` | Delivery icon | "View Orders" → `/orders` |
| `SellerDashboardScreen` | Store icon | "View Orders" → `/orders` |
| `AdminDashboardScreen` | Admin icon | "All Orders" → `/orders` |

Each dashboard shows:
- Role-specific icon in a rounded container
- Role title (e.g., "Rider Dashboard")
- User name from `currentUserProvider`
- Prominent "View Orders" / "All Orders" button
- "Sign Out" text button

---

## 💾 Data Models

### OrderListItemModel (Freezed — `packages/orders/`)

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `id` | `String` | Document ID | Firestore order ID |
| `userId` | `String` | Top-level field | User's UID |
| `userName` | `String` | Top-level field | User's display name |
| `shopId` | `String` | Top-level field | Shop reference |
| `shopName` | `String` | Top-level field | Shop display name |
| `deliveryAddressLine` | `String` | `deliveryAddress.addressLine` | Human-readable address |
| `total` | `double` | Top-level field | Order total |
| `itemCount` | `int` | Computed from `items.length` | Number of items |
| `status` | `String` | Top-level field | Order status |
| `createdAt` | `DateTime` | Top-level field | Order creation time |

### Flattened Order Document (`orders/{orderId}`)

```json
{
  "userId": "abc123",
  "userName": "John Doe",
  "userPhone": "+96170123456",
  "shopId": "shop_xyz",
  "shopName": "Pizza Palace",
  "items": [ ... ],
  "deliveryAddress": {
    "latitude": 33.8938,
    "longitude": 35.5018,
    "addressLine": "123 Main St, Beirut",
    "label": "Current Location"
  },
  "subtotal": 12.99,
  "deliveryFee": 2.50,
  "total": 15.49,
  "status": "Waiting Rider Confirmation",
  "createdAt": Timestamp
}
```

---

## 🎨 Theming

All widgets use:
- `AppColors.*` for colors
- `AppDimens.*` for spacing, padding, border radius
- `Theme.of(context).textTheme.*` for typography

### Color Usage in Orders List

| Token | Usage |
|-------|-------|
| `AppColors.primary` | Order total, active filter chips |
| `AppColors.background` | Screen background |
| `AppColors.surface` | Card background |
| `AppColors.surfaceVariant` | Card borders, shimmer |
| `AppColors.onBackground` | Shop name, labels |
| `AppColors.textSecondary` | Address, item count, time |
| `AppColors.textHint` | Time ago text |
| `AppColors.success` / `AppColors.successLight` | Delivered badge |
| `AppColors.error` / `AppColors.errorLight` | Cancelled badge |
| `AppColors.warning` / `AppColors.warningLight` | Active status badges |

---

## 🔥 Firebase Integration

### Firestore Security Rules (`firestore.rules`)

The orders collection rules are updated to use the flattened `userId` field instead of the previous nested `user.Id`:

```javascript
match /orders/{orderId} {
  allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
  allow read: if hasRole('rider') && resource.data.riderId == request.auth.uid;
  allow read: if hasRole('seller') && resource.data.sellerId == request.auth.uid;
  allow read: if isAdmin();
  allow create: if isAuthenticated();
  // ... update rules, delete rule
}
```

### Composite Indexes (in `firestore.indexes.json`)

The existing orders indexes are used:

| Index | Fields | Used For |
|-------|--------|----------|
| 1 | `userId ASC`, `createdAt DESC` | User role query + default ordering |
| 2 | `riderId ASC`, `status ASC` | Rider role query |
| 3 | `sellerId ASC`, `createdAt DESC` | Seller role query |
| 4 | `status ASC`, `createdAt DESC` | Admin with status filter |

No new indexes were needed — the flattened `userId` field now matches the existing index.

---

## 🚀 Cross-Feature Integration

### Checkout Feature Integration
The `OrderModel` in `apps/user_app/features/checkout/data/models/order_model.dart` was refactored:
- Removed nested `user` object (`OrderUserInfo`)
- Added top-level fields: `userId`, `userName`, `userPhone`
- Removed `userEmail` (not needed)
- Updated `CheckoutNotifier.placeOrder()` to use flat fields

### Bottom Navigation Integration
- **All apps**: Orders tab added to shared `MainShell` bottom navigation bar (see `packages/core/lib/widgets/main_shell.dart`)
- **user_app**: "My Orders" icon button removed from search bar row in `DashboardScreen` — replaced by the bottom nav Orders tab
- **rider_app/seller_app/admin_panel**: Flat `/orders` route replaced by bottom nav Orders tab via `StatefulShellRoute.indexedStack`

---

## 📝 Conventions for Future Changes

### ✅ DO:
1. **Add new status filters** in `_statusesForFilter()` in `order_list_datasource.dart`
2. **Add new fields** to `OrderListItemModel` → update `fromFirestore()`
3. **Handle errors** using `Result<T>` pattern
4. **Use `AppColors`/`AppDimens`** — no hardcoded values
5. **Run `build_runner`** in `packages/orders/` after model/provider changes
6. **Update this doc** after making changes

### ❌ DON'T:
1. **Don't call Firestore directly from widgets** — go through `OrderListNotifier`
2. **Don't hardcode colors/spacing** — use theme constants
3. **Don't add app-specific logic** to the shared order list package
4. **Don't forget to regenerate** code with `build_runner`

---

## 🧪 Testing (Future)

**Current Tests:** None specific to orders list  
**Future Tests Needed:**
- Unit tests for `OrderListNotifier` (filter, paginate, refresh)
- Unit tests for `OrderListDataSource` (mock Firestore)
- Unit tests for `OrderListItemModel` (fromFirestore, toJson)
- Widget tests for `OrderCard` (all statuses)
- Widget tests for `OrdersListScreen` (loading, empty, error, data states)
- Integration tests for order flow (checkout → orders list)

---

**End of Orders List Feature Specification**
