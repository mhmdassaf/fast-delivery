# Checkout Feature Specification

> **AI-Readable Documentation for Checkout Feature**  
> **Last Updated:** 2026-05-23  
> **Feature Status:** ✅ Implemented  
> **Commit:** `pending` (see `firestore.rules` for order security rules)

---

## 📋 Feature Overview

**Purpose:** Order checkout flow for the Fast Delivery User App  
**Scope:** Delivery address selection, order summary, place order to Firestore  
**Persistent Storage:** Orders saved to Firestore `orders` collection  
**Platform:** Flutter (Android, iOS)  
**Architecture:** App-specific feature (`apps/user_app/lib/features/checkout/`)

---

## 📁 Files & Structure

```
apps/user_app/lib/features/checkout/
├── data/
│   ├── datasources/
│   │   ├── checkout_datasource.dart       # Firestore: create order, get shop delivery info
│   │   └── location_datasource.dart       # Geolocator + Geocoding for device location
│   ├── models/
│   │   ├── delivery_address_model.dart    # Freezed — address with lat/lng
│   │   ├── delivery_address_model.freezed.dart
│   │   ├── delivery_address_model.g.dart
│   │   ├── order_model.dart               # Freezed — Firestore order document
│   │   ├── order_model.freezed.dart
│   │   ├── order_model.g.dart
│   │   ├── order_user_info.dart           # Freezed — nested user inside order
│   │   ├── order_user_info.freezed.dart
│   │   └── order_user_info.g.dart
│   └── repositories/
│       ├── checkout_repository.dart       # Wraps CheckoutDataSource
│       └── location_repository.dart       # Wraps LocationDataSource
├── domain/
│   └── providers/
│       ├── checkout_providers.dart        # CheckoutNotifier + CheckoutState + infrastructure
│       └── checkout_providers.g.dart      # Generated
└── presentation/
    ├── pages/
    │   └── checkout_screen.dart           # Main checkout screen
    └── widgets/
        ├── delivery_time_section.dart     # Non-editable delivery time display
        ├── delivery_address_section.dart  # Address card + Change bottom sheet
        ├── order_summary_section.dart     # SubTotal, Delivery Fee, Total
        └── place_order_banner.dart        # Fixed bottom banner (Total + Place Order)
```

### Supporting Changes in Other Files

| File | Change |
|------|--------|
| `apps/user_app/lib/main.dart` | Added `/checkout` route (outside ShellRoute) |
| `apps/user_app/lib/features/cart/presentation/pages/my_cart_screen.dart` | Replaced SnackBar placeholder with `context.push('/checkout')` |
| `packages/core/lib/errors/failure.dart` | Added `CheckoutFailure` class |
| `apps/user_app/pubspec.yaml` | Added `geolocator: ^13.0.2`, `geocoding: ^3.0.0` |

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure (in `apps/user_app/lib/features/checkout/`)

```
lib/features/checkout/
├── data/                         # Data layer
│   ├── datasources/              # Firebase + Geolocator operations
│   ├── models/                    # Freezed data models
│   └── repositories/             # Data source wrappers
├── domain/                       # Domain layer
│   └── providers/
│       └── checkout_providers.dart # CheckoutNotifier + CheckoutState + providers
└── presentation/                 # Presentation layer
    ├── pages/
    │   └── checkout_screen.dart    # Main checkout page
    └── widgets/                    # Reusable UI sections
```

### Key Principles
- **Data Layer:** `CheckoutDataSource` handles Firestore; `LocationDataSource` handles device GPS
- **Domain Layer:** `CheckoutNotifier` manages checkout state, fetches shop info, validates address, places orders
- **Presentation Layer:** UI components consuming providers via `ConsumerStatefulWidget`
- **Cart integration:** Reads from `cartNotifierProvider`, clears cart after successful order

---

## 🛒 Checkout Flow

### 1. Enter Checkout Screen
**Entry Point:** `my_cart_screen.dart` → Checkout button → `context.push('/checkout')`

**Flow:**
1. `CheckoutNotifier.build()` triggers:
   - `_loadShopInfo()` — fetches shop document from Firestore for `deliveryTime` and `deliveryFee` using `cartShopIdProvider`
   - `_loadInitialAddress()` — requests device location via geolocator + reverse geocoding
2. While loading, UI shows `LinearProgressIndicator` in the delivery time section
3. On shop info failure → error message displayed
4. On location failure → address section shows "No address set" (manual entry fallback)

### 2. Phone Number (Pre-fill from Firestore)

When the checkout screen loads, `CheckoutNotifier._loadInitialPhone()`:
1. Reads the authenticated user's `uid`
2. Calls `CheckoutRepository.getUserPhone(userId)` → reads `phoneNumber` from `users/{uid}` Firestore document
3. If a phone number exists (e.g. `"+96171234567"`), strips the country code prefix and pre-fills `state.phoneNumber` (e.g. `"71234567"`)
4. The `PhoneNumberSection` widget listens for this value and auto-fills the text field
5. If no phone number exists, the field stays empty — the user must enter it

### 3. Set Delivery Address

**Two options via bottom sheet (triggered by "Change" button):**

**Option A: Use Current Location**
1. `showAddressOptionsSheet` returns `'use_device'`
2. `CheckoutNotifier.useDeviceLocation()`:
   - Calls `LocationRepository.getCurrentAddress()`
   - On success → updates `state.deliveryAddress`
   - On failure → sets `state.errorMessage`

**Option B: Enter Manually**
1. `showAddressOptionsSheet` returns `'set_manual'`
2. A dialog with a `TextFormField` opens for address input
3. On submit → creates `DeliveryAddressModel(latitude: 0.0, longitude: 0.0, addressLine: userInput, label: 'Manual')`
4. `CheckoutNotifier.setAddress(address)` updates state

### 4. Place Order

**Trigger:** User taps "Place Order" button in `PlaceOrderBanner`

**Validation:**
- If `deliveryAddress == null` → shows error SnackBar: "Please set your delivery address"
- If cart is empty → shows error SnackBar (edge case guard)
- If `phoneNumber` is empty → shows error SnackBar: "Please enter your phone number"

**Order Creation:**
1. Set `isPlacingOrder = true` (button shows loading spinner, becomes disabled)
2. Build `OrderModel`:
   - `user` = `OrderUserInfo(id: userId, name: userName, email: userEmail, phone: fullPhone)`
     - `userId` from `currentUserProvider.uid`
     - `userName` from `currentUserProvider.displayName`
     - `userEmail` from `currentUserProvider.email`
     - `fullPhone` = `'+961$phone'` (entered phone with Lebanon country code)
   - `shopId`, `shopName` from cart providers
   - `items` snapshot from `cartNotifierProvider`
   - `subtotal` from `cartTotalProvider`
   - `deliveryFee` from state (fetched from shop)
   - `total = subtotal + deliveryFee`
   - `deliveryAddress` from state
   - `deliveryTimeLabel` from state (fetched from shop)
   - `status = "Waiting Rider Confirmation"`
3. `CheckoutRepository.createOrder(order)` → Firestore `orders.add(order.toFirestore())`
4. On success:
   - **Update user's phone** in `users/{uid}` via `CheckoutRepository.updateUserPhone(userId, fullPhone)`
   - Clear cart via `CartNotifier.clearCart()`
   - Set `state.createdOrderId`
   - Navigate to `/` (Dashboard) with success SnackBar
5. On failure:
   - Set `isPlacingOrder = false`
   - Show error SnackBar with failure message

---

## 📊 State Management (Riverpod)

### Providers (in `apps/user_app/lib/features/checkout/domain/providers/checkout_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `checkoutFirestoreProvider` | `@riverpod` | `FirebaseFirestore` instance |
| `checkoutDataSourceProvider` | `@riverpod` | `CheckoutDataSourceImpl` |
| `checkoutRepositoryProvider` | `@riverpod` | `CheckoutRepositoryImpl` |
| `locationDataSourceProvider` | `@riverpod` | `LocationDataSourceImpl` |
| `locationRepositoryProvider` | `@riverpod` | `LocationRepositoryImpl` |
| `checkoutNotifierProvider` | `@riverpod` Notifier | **Core state** — `CheckoutNotifier` |

### CheckoutState Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `deliveryAddress` | `DeliveryAddressModel?` | `null` | Selected delivery address |
| `deliveryTimeLabel` | `String` | `''` | Shop's delivery time (e.g. "30-45 min") |
| `deliveryFee` | `double` | `0.0` | Shop's delivery fee |
| `isLoadingShopInfo` | `bool` | `false` | Loading shop Firestore data |
| `isPlacingOrder` | `bool` | `false` | Order being submitted |
| `errorMessage` | `String?` | `null` | Current error to display |
| `createdOrderId` | `String?` | `null` | Order ID after successful creation |

### CheckoutNotifier Methods

| Method | Description |
|--------|-------------|
| `build()` | Initialize: load shop info + initial address + phone pre-fill |
| `_loadInitialPhone()` | Fetch user's phone from `users/{uid}` Firestore doc → pre-fill state |
| `setAddress(DeliveryAddressModel)` | Set address manually |
| `setPhoneNumber(String)` | Set the phone number from user input |
| `useDeviceLocation()` | Fetch device GPS and set as address |
| `placeOrder()` | Validate → create Firestore order → update user phone → clear cart |
| `clearError()` | Clear error message |

---

## 🧭 Navigation (GoRouter)

**Router Config:** `apps/user_app/lib/main.dart` → `routerProvider`

### Route Structure
```
/login            ← Auth route (outside ShellRoute)
/register         ← Auth route (outside ShellRoute)
/                 ← Dashboard (inside ShellRoute with ViewCartBanner)
/shop/:shopId     ← Shop details (inside ShellRoute)
/item-details     ← Item detail + add to cart (inside ShellRoute)
/my-cart          ← Cart management (outside ShellRoute)
/checkout         ← Checkout screen (outside ShellRoute — no ViewCartBanner)
```

### Route Arguments
- `/checkout` — no arguments needed; reads from cart and auth providers directly

---

## 🎨 UI Components

### Screens

| Screen | File | Purpose |
|--------|------|---------|
| `CheckoutScreen` | `pages/checkout_screen.dart` | Main checkout: scrollable sections + fixed bottom banner |

### Widgets

| Widget | File | Purpose |
|--------|------|---------|
| `DeliveryTimeSection` | `widgets/delivery_time_section.dart` | Card showing shop delivery time with loading indicator |
| `DeliveryAddressSection` | `widgets/delivery_address_section.dart` | Card showing address + "Change" button |
| `OrderSummarySection` | `widgets/order_summary_section.dart` | SubTotal, Delivery Fee, Total rows |
| `PlaceOrderBanner` | `widgets/place_order_banner.dart` | Fixed bottom bar with total + Place Order button |
| `_SummaryRow` | `widgets/order_summary_section.dart` | Label-value row helper |
| `AddressOptionsSheet` | `widgets/delivery_address_section.dart` | Bottom sheet with "Use Current Location" / "Enter Manually" |

### PlaceOrderBanner Details
- Styled with `AppColors.primary` background (same as `ViewCartBanner`)
- Left side: "Total Payment" label + amount in bold
- Right side: "Place Order" `ElevatedButton` with white background
- Button shows `CircularProgressIndicator` while `isPlacingOrder`
- Button disabled during loading or placing

### Address Bottom Sheet
- Title: "Set Delivery Address"
- Option 1: "Use Current Location" — `ElevatedButton` with `my_location` icon
- Option 2: "Enter Manually" — `OutlinedButton` with `edit` icon
- Returns `'use_device'` or `'set_manual'` via `Navigator.pop`

---

## 💾 Data Models

### DeliveryAddressModel (Freezed)
**File:** `apps/user_app/lib/features/checkout/data/models/delivery_address_model.dart`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `latitude` | `double` | required | GPS latitude |
| `longitude` | `double` | required | GPS longitude |
| `addressLine` | `String` | required | Human-readable address |
| `label` | `String` | `'Current Location'` | User-friendly label |

**Methods:** `fromMap()`, `toMap()`, `get geoPoint` (to `GeoPoint`)

### OrderUserInfo (Freezed)
**File:** `apps/user_app/lib/features/checkout/data/models/order_user_info.dart`

Nested model embedded inside `OrderModel.user` with capital-letter Firestore keys.

| Dart Field | Firestore Key | Type | Default | Description |
|------------|---------------|------|---------|-------------|
| `id` | `Id` | `String` | required | Auth user UID |
| `name` | `Name` | `String` | `''` | User's display name (from auth profile) |
| `email` | `Email` | `String` | `''` | User's email (from auth profile) |
| `phone` | `Phone` | `String?` | `null` | User's phone (with country code, e.g. `+96170123456`) |

**Methods:** `toFirestore()` (delegates to `toJson()` → capital-letter keys)

### OrderModel (Freezed)
**File:** `apps/user_app/lib/features/checkout/data/models/order_model.dart`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `String` | required | Firestore document ID |
| `user` | `OrderUserInfo` | required | Nested user data (Id, Name, Email, Phone) |
| `shopId` | `String` | required | Shop being ordered from |
| `shopName` | `String` | required | Shop display name |
| `items` | `List<CartItemModel>` | required | Snapshot of cart items |
| `deliveryAddress` | `DeliveryAddressModel` | required | Delivery destination |
| `deliveryTimeLabel` | `String` | required | Shop delivery time estimate |
| `subtotal` | `double` | required | Sum of item prices |
| `deliveryFee` | `double` | required | Shop delivery charge |
| `total` | `double` | required | subtotal + deliveryFee |
| `status` | `String` | `'Waiting Rider Confirmation'` | Order lifecycle status |
| `createdAt` | `DateTime?` | `null` | Firestore server timestamp |

**Methods:** `fromFirestore()`, `toFirestore()`

### Firestore Document Structure (`orders/{orderId}`)
```json
{
  "user": {
    "Id": "abc123...",
    "Name": "John Doe",
    "Email": "john@example.com",
    "Phone": "+96170123456"
  },
  "shopId": "shop_xyz",
  "shopName": "Pizza Palace",
  "items": [
    {
      "id": "item_1",
      "name": "Margherita Pizza",
      "price": 12.99,
      "quantity": 1
    }
  ],
  "deliveryAddress": {
    "latitude": 33.8938,
    "longitude": 35.5018,
    "addressLine": "123 Main St, Beirut",
    "label": "Current Location"
  },
  "deliveryTimeLabel": "30-45 min",
  "subtotal": 12.99,
  "deliveryFee": 2.50,
  "total": 15.49,
  "status": "Waiting Rider Confirmation",
  "createdAt": "2026-05-23T..."
}
```

---

## 🎨 Theming

Uses existing `AppColors` and `AppDimens` from `packages/core/lib/constants/app_constants.dart`.

### AppDimens Used
| Constant | Usage |
|----------|-------|
| `AppDimens.paddingXS` | Section spacing |
| `AppDimens.paddingS` | Internal spacing |
| `AppDimens.paddingM` | Card padding |
| `AppDimens.paddingL` | Banner padding, button insets |
| `AppDimens.paddingXL` | Bottom sheet padding |
| `AppDimens.radiusM` | Card / button border radius |
| `AppDimens.radiusL` | Card border radius |
| `AppDimens.radiusXL` | Bottom sheet top radius |
| `AppDimens.iconM` | Section icons size |
| `AppDimens.buttonHeight` | Address sheet button height |
| `AppDimens.buttonHeightSmall` | Place Order button height |

### AppColors Used
| Constant | Usage |
|----------|-------|
| `AppColors.primary` | Icons, button backgrounds, total text |
| `AppColors.primaryLight` | Icon container backgrounds |
| `AppColors.onPrimary` | Banner text, Place Order button text |
| `AppColors.onBackground` | Primary content text |
| `AppColors.textSecondary` | Labels, secondary text |
| `AppColors.textHint` | Placeholder text |
| `AppColors.surfaceVariant` | Card borders |
| `AppColors.success` | Success SnackBar |
| `AppColors.error` | Error SnackBar, error text |

### CheckoutFailure (in `packages/core/lib/errors/failure.dart`)
| Factory | Message |
|---------|---------|
| `CheckoutFailure.addressNotSet()` | "Please set your delivery address" |
| `CheckoutFailure.phoneNumberRequired()` | "Please enter your phone number" |
| `CheckoutFailure.createOrderFailed(msg?)` | "Failed to place order" |
| `CheckoutFailure.locationFailed(msg?)` | "Failed to get your location" |
| `CheckoutFailure.shopInfoFailed(msg?)` | "Failed to load shop information" |
| `CheckoutFailure.phoneUpdateFailed(msg?)` | "Failed to update phone number" |

### Phone Number Flow Summary
1. **On checkout load**: `CheckoutNotifier._loadInitialPhone()` fetches `phoneNumber` from Firestore `users/{uid}` and pre-fills the phone input
2. **User input**: `PhoneNumberSection` widget strips non-digits, stores local number (e.g. `71234567`) in `state.phoneNumber`
3. **On place order**: `OrderModel.user.phone` = `'$kLebanonCountryCode$phone'` = `'+96171234567'` (full number with country code from shared constant `kLebanonCountryCode`, stored under Firestore key `Phone`)
4. **After order created**: `updateUserPhone()` saves the full number back to Firestore `users/{uid}.phoneNumber` so it persists for future orders

---

## 📦 Dependencies (in `apps/user_app/pubspec.yaml`)

### Packages used by Checkout Feature
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod code gen |
| `go_router` | ^14.8.1 | Navigation |
| `geolocator` | ^13.0.2 | GPS location |
| `geocoding` | ^3.0.0 | Reverse geocoding |
| `cloud_firestore` | ^5.6.7 | Firestore orders |
| `freezed_annotation` | ^3.0.0 | Data models |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `fast_delivery_core` | path: | Shared constants, errors, Result |
| `fast_delivery_auth` | path: | Auth state for userId |

### Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `build_runner` | ^2.4.15 | Code generation |
| `freezed` | ^3.0.0 | Freezed code gen |
| `json_serializable` | ^6.9.4 | JSON code gen |
| `riverpod_generator` | ^2.6.5 | Riverpod code gen |

---

## 🔄 How to Modify This Feature

### Adding a New Field to OrderModel
1. Add field to `OrderModel` in `data/models/order_model.dart`
2. Update `fromFirestore()` and `toFirestore()` methods
3. Run `dart run build_runner build --delete-conflicting-outputs` in `apps/user_app/`
4. Update **this doc** with new field

### Adding a New Checkout Step
1. Add state field to `CheckoutState` in `domain/providers/checkout_providers.dart`
2. Add method to `CheckoutNotifier`
3. Create widget in `presentation/widgets/`
4. Add widget to `CheckoutScreen` body
5. Update **this doc**

### Changing Address Picker UI
1. Modify `showAddressOptionsSheet` in `widgets/delivery_address_section.dart`
2. Update return values and handling in `CheckoutScreen._onChangeAddress()`
3. Update **this doc**

---

## ⚠️ Error Handling

### Graceful Degradation
- **Location unavailable:** Shows "No address set" — user can enter manually
- **Location permission denied:** Shows specific message ("permanently denied" guides user to settings)
- **Geocoding failure:** Falls back to showing coordinates as address
- **Shop info fetch fails:** Shows error message; `deliveryFee` defaults to 0.0
- **Order creation fails:** Button re-enables, error SnackBar shown
- **Cart empty (edge case):** Guard returns early with error

### CheckoutFailure Types
- `addressNotSet()` — shown when Place Order tapped without address
- `phoneNumberRequired()` — shown when Place Order tapped without phone number
- `createOrderFailed()` — Firestore write failure for order
- `locationFailed()` — GPS or permission failure
- `shopInfoFailed()` — Shop Firestore document fetch failure
- `phoneUpdateFailed()` — Firestore write failure when saving phone to user doc

### Location Accuracy
- Uses `LocationAccuracy.medium` (not `high`) to balance precision with battery life
- Address lookup via device location occurs on checkout screen load and when user taps "Use Current Location"
- On failure: falls back to manual address entry (graceful degradation)

---

## 🧪 Testing (TODO)

**Current Tests:** None specific to checkout feature  
**Future Tests Needed:**
- Unit tests for `CheckoutNotifier` (setAddress, useDeviceLocation, placeOrder)
- Unit tests for `LocationDataSourceImpl` (mock geolocator + geocoding)
- Unit tests for `CheckoutDataSourceImpl` (mock Firestore)
- Widget tests for `DeliveryTimeSection` (loading vs loaded)
- Widget tests for `DeliveryAddressSection` (set vs unset)
- Widget tests for `OrderSummarySection` (values display)
- Widget tests for `PlaceOrderBanner` (enabled/disabled states)
- Widget tests for `CheckoutScreen` (full flow, address change, order placement)
- Integration test for checkout flow (cart → checkout → place order)

---

## 📝 Conventions for Future Changes

### ✅ DO:
1. **Use `CheckoutNotifier` methods** for all state mutations
2. **Use `Result<T>` pattern** for all data source operations
3. **Pass callbacks** to private widgets (avoid `WidgetRef ref` in non-provider widgets)
4. **Use `AppDimens` and `AppColors`** — no hardcoded values
5. **Clear cart after successful order** via `CartNotifier.clearCart()`
6. **Show SnackBars for errors** (error text, `AppColors.error` background)
7. **Show SnackBars for success** (green, `AppColors.success` background)
8. **Handle loading states** — disable buttons, show progress indicators
9. **Generate code** after changing providers/models:
   ```bash
   cd apps/user_app
   dart run build_runner build --delete-conflicting-outputs
   ```

### ❌ DON'T:
1. **Don't call Firestore directly from UI** — go through DataSource → Repository → Notifier
2. **Don't modify state outside `CheckoutNotifier`** — always use notifier methods
3. **Don't hardcode colors/spacing** — use theme constants
4. **Don't place order without address validation** — always check `deliveryAddress != null`
5. **Don't forget to clear cart** after successful order placement
6. **Don't leave stale error messages** — clear them on new actions

---

## 🚀 Quick Reference for AI Agents

**When modifying the checkout feature, always:**
1. Read this file first (`docs/checkout_feature.md`)
2. Read `docs/cart_feature.md` for cart integration context
3. Follow Clean Architecture layers (data/models → domain/providers → presentation/pages+widgets)
4. Use `CheckoutNotifier` for all state changes
5. Use `Result<T>` pattern for all async operations
6. Use `AppColors`/`AppDimens` from `package:fast_delivery_core/constants/app_constants.dart`
7. Handle loading, error, and success states for all async operations
8. Run `build_runner` after provider/model changes
9. Update **this doc** after making changes

**Key Files to Review:**
- `apps/user_app/lib/features/checkout/domain/providers/checkout_providers.dart` — State management
- `apps/user_app/lib/features/checkout/data/models/order_model.dart` — Order data model
- `apps/user_app/lib/features/checkout/data/models/delivery_address_model.dart` — Address model
- `apps/user_app/lib/features/checkout/data/datasources/checkout_datasource.dart` — Firestore ops
- `apps/user_app/lib/features/checkout/data/datasources/location_datasource.dart` — GPS ops
- `apps/user_app/lib/features/checkout/presentation/pages/checkout_screen.dart` — Checkout UI
- `apps/user_app/lib/features/checkout/presentation/widgets/place_order_banner.dart` — Bottom banner
- `apps/user_app/lib/main.dart` — Route registration
- `packages/core/lib/errors/failure.dart` — CheckoutFailure definitions

**Common Pitfalls:**
- Forgetting to import `CheckoutFailure` / `CartFailure` from `package:fast_delivery_core/errors/failure.dart`
- Using wrong import path between `data/` and `presentation/` subdirectories
- Calling `Result.failure(CheckoutFailure.addressNotSet() as Failure)` — `as Failure` cast is unnecessary since `CheckoutFailure` already extends `Failure`
- Not handling `ref.listen` for order success navigation (causes double-navigation or no navigation)
- Forgetting to call `clearCart()` after successful order placement
- Not disposing `TextEditingController` in the manual address dialog
- Using `ref.listenManual` instead of `ref.listen` inside `build()`

---

**End of Checkout Feature Specification**
