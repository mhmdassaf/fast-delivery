# Auth Feature Specification

> **AI-Readable Documentation for Auth Feature**  
> **Last Updated:** 2026-05-06  
> **Feature Status:** ✅ Implemented  
> **Commit:** `b556f35` - refactor(customer_app): restructure app with Clean Architecture and Firebase authentication

---

## 📋 Feature Overview

**Purpose:** Authentication system for ALL Fast Delivery apps (Customer, Seller, Rider, Admin)  
**Scope:** Login, Registration, Password Reset, Google Sign-In, Auth State Management  
**Roles Supported:** `customer` (default), `rider`, `seller`, `admin`  
**Platform:** Flutter (iOS, Android, Web)  
**Architecture:** Shared packages (no code duplication)

---

## 📦 Shared Packages Structure

To avoid code duplication, the auth feature is implemented as **shared packages** that all apps use:

```
packages/
├── core/                          # Shared core modules
│   ├── lib/
│   │   ├── constants/              # AppConstants, dimensions
│   │   ├── errors/                 # Failure, Result types
│   │   ├── firebase/               # Firebase options
│   │   ├── theme/                  # AppTheme (light/dark)
│   │   ├── utils/                  # Validators
│   │   └── widgets/               # Reusable widgets
│   └── pubspec.yaml
│
└── auth/                          # Shared auth feature
    ├── lib/
    │   ├── data/                   # Data layer
    │   │   ├── datasources/
    │   │   │   └── auth_datasource.dart
    │   │   ├── models/
    │   │   │   ├── user_model.dart
    │   │   │   └── user_model.g.dart
    │   │   └── repositories/
    │   │       └── auth_repository.dart
    │   ├── domain/                # Domain layer
    │   │   └── providers/
    │   │       ├── auth_providers.dart
    │   │       └── auth_providers.g.dart
    │   ├── presentation/          # Presentation layer
    │   │   ├── helpers/
    │   │   │   └── auth_helpers.dart
    │   │   ├── screens/
    │   │   │   ├── auth_gate.dart
    │   │   │   ├── login_screen.dart
    │   │   │   └── register_screen.dart
    │   │   └── widgets/
    │   │       ├── auth_header.dart
    │   │       └── password_strength_indicator.dart
    │   └── shared/               # Shared widgets (from customer_app)
    │       └── widgets/
    │           ├── auth_error_message.dart
    │           ├── auth_text_field.dart
    │           ├── loading_overlay.dart
    │           ├── primary_button.dart
    │           └── social_login_button.dart
    └── pubspec.yaml
```

### Package Dependencies:
- **fast_delivery_core** - Used by all apps for core modules
- **fast_delivery_auth** - Used by all apps for auth feature (depends on core)

### Apps Using Shared Packages:
```
apps/
├── customer_app/      → uses fast_delivery_core + fast_delivery_auth
├── seller_app/        → uses fast_delivery_core + fast_delivery_auth
├── rider_app/         → uses fast_delivery_core + fast_delivery_auth
└── admin_panel/       → uses fast_delivery_core + fast_delivery_auth
```

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure (in `packages/auth/`)

The auth feature follows Clean Architecture and is implemented as a shared package:

```
packages/auth/lib/
├── data/
│   ├── datasources/
│   │   └── auth_datasource.dart       # Firebase Auth + Firestore operations
│   ├── models/
│   │   ├── user_model.dart            # Freezed data model
│   │   └── user_model.g.dart         # Generated code
│   └── repositories/
│       └── auth_repository.dart       # Repository implementation
├── domain/
│   ├── entities/                     # (Reserved for future use)
│   └── providers/
│       ├── auth_providers.dart        # Riverpod providers + AuthNotifier
│       └── auth_providers.g.dart     # Generated code
└── presentation/
    ├── helpers/
    │   └── auth_helpers.dart         # Reusable auth UI logic
    ├── screens/
    │   ├── auth_gate.dart            # Auth state router
    │   ├── login_screen.dart        # Login UI
    │   └── register_screen.dart     # Registration UI
    └── widgets/
        ├── auth_header.dart          # Reusable header widget
        └── password_strength_indicator.dart
```

### Shared Core Package (`packages/core/`)

Core modules used by all apps and the auth package:

```
packages/core/lib/
├── constants/
│   └── app_constants.dart            # AppColors, AppDimens
├── errors/
│   ├── failure.dart                  # Failure types (AuthFailure, etc.)
│   └── result.dart                   # Result<T> success/failure pattern
├── firebase/
│   └── firebase_options.dart        # Firebase configuration
├── theme/
│   └── app_theme.dart               # AppTheme (light/dark)
├── utils/
│   └── validators.dart              # Form validation helpers
└── widgets/                         # Shared UI widgets
    ├── auth_error_message.dart
    ├── auth_text_field.dart
    ├── loading_overlay.dart
    ├── primary_button.dart
    └── social_login_button.dart
```

### Key Principles
- **Data Layer:** Handles Firebase Auth + Firestore operations via `AuthDataSource` (in `packages/auth/`)
- **Domain Layer:** Contains business logic via Riverpod `AuthNotifier` and repository interfaces (in `packages/auth/`)
- **Presentation Layer:** UI components (screens, widgets) that consume providers (in `packages/auth/`)
- **Core Layer:** Shared utilities, themes, widgets, and error handling (in `packages/core/`)

---

## 🔐 Authentication Flows

### 1. Email/Password Login
**Entry Point:** `packages/auth/lib/presentation/screens/login_screen.dart` → `_handleSignIn()`
```dart
// Provider call
await ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(
  email: emailController.text,
  password: passwordController.text,
);
```
**Flow:**
1. Validate form inputs (email format, password length)
2. Call `AuthNotifier.signInWithEmailAndPassword()`
3. `AuthNotifier` → `AuthRepository` → `AuthDataSource`
4. Firebase `signInWithEmailAndPassword()`
5. Fetch/Create user document in Firestore `users/{uid}`
6. Update `lastLoginAt` timestamp
7. Return `UserModel` → Update `AuthState`

### 2. Email/Password Registration
**Entry Point:** `packages/auth/lib/presentation/screens/register_screen.dart` → `_handleSignUp()`
```dart
await ref.read(authNotifierProvider.notifier).signUpWithEmailAndPassword(
  email: emailController.text,
  password: passwordController.text,
  displayName: nameController.text,
);
```
**Flow:**
1. Validate form (email, password strength, matching passwords)
2. Call `AuthNotifier.signUpWithEmailAndPassword()`
3. Firebase `createUserWithEmailAndPassword()`
4. Update display name in Firebase Auth
5. **Poll Firestore** (up to 5 seconds) for Cloud Function to create user document
6. Fallback: Manually create user document if CF hasn't run
7. Return `UserModel`

### 3. Google Sign-In
**Entry Point:** `packages/auth/lib/presentation/screens/login_screen.dart` or `register_screen.dart` → `_handleGoogleSignIn()`
```dart
await ref.read(authNotifierProvider.notifier).signInWithGoogle();
```
**Flow:**
1. `GoogleSignIn().signIn()` → Get Google account
2. Get `accessToken` + `idToken` from Google Auth
3. Create Firebase `GoogleAuthProvider.credential()`
4. Firebase `signInWithCredential()`
5. Check if user exists in Firestore `users/{uid}`
6. If new: Create user document with defaults
7. If existing: Update `lastLoginAt`
8. Return `UserModel`

### 4. Password Reset
**Entry Point:** `packages/auth/lib/presentation/screens/login_screen.dart` → `_handleForgotPassword()`
```dart
await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
  email: emailController.text,
);
```
**Flow:**
1. Validate email is entered
2. Call `FirebaseAuth.sendPasswordResetEmail()`
3. Show confirmation SnackBar

---

## 📊 State Management (Riverpod)

### Providers (in `packages/auth/lib/domain/providers/auth_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `firebaseAuthProvider` | `@riverpod` | Exposes `FirebaseAuth.instance` |
| `authDataSourceProvider` | `@riverpod` | Creates `AuthDataSourceImpl` |
| `authRepositoryProvider` | `@riverpod` | Creates `AuthRepositoryImpl` |
| `authStateChangesProvider` | `@riverpod` | Stream of `UserModel?` from Firebase auth state |
| `currentUserProvider` | `@riverpod` | Synchronous current user (nullable) |
| `authStatusProvider` | `@riverpod` | Enum: `initial`, `authenticated`, `unauthenticated` |
| `authNotifierProvider` | `@riverpod` (Notifier) | **Main state manager** - `AuthNotifier` class |

### AuthNotifier State
```dart
class AuthState {
  final UserModel? user;     // Current authenticated user
  final bool isLoading;      // Loading indicator flag
  final String? errorMessage; // Error message (null if no error)
}
```

### AuthNotifier Methods
- `signInWithEmailAndPassword()` → Returns `bool` (success/failure)
- `signUpWithEmailAndPassword()` → Returns `bool`
- `signInWithGoogle()` → Returns `bool`
- `signOut()` → Returns `bool`
- `sendPasswordResetEmail()` → Returns `bool`
- `updateProfile()` → Returns `bool`
- `clearError()` → Void (clears error message)

---

## 🧭 Navigation (GoRouter)

**Router Config:** Defined in each app's `main.dart` (e.g., `apps/customer_app/lib/main.dart`) → `_router`

**Import from package:**
```dart
import 'package:fast_delivery_auth/presentation/screens/auth_gate.dart';
import 'package:fast_delivery_auth/presentation/screens/login_screen.dart';
import 'package:fast_delivery_auth/presentation/screens/register_screen.dart';
```

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | `AuthGate` | **Smart router** - redirects based on auth state |
| `/login` | `LoginScreen` | Email/password login + Google Sign-In |
| `/register` | `RegisterScreen` | New user registration |

### AuthGate Logic
```dart
// In packages/auth/lib/presentation/screens/auth_gate.dart
final authStatus = ref.watch(authStatusProvider);

if (authStatus == AuthStatus.authenticated) {
  return HomeScreen(); // TODO: Implement home screen in each app
} else {
  return LoginScreen(); // Redirect to login
}
```

---

## 🔥 Firebase Integration

### Firebase Auth Methods Used (in `packages/auth/lib/data/datasources/auth_datasource.dart`)
- `signInWithEmailAndPassword()`
- `createUserWithEmailAndPassword()`
- `signInWithCredential()` (Google Sign-In)
- `signOut()`
- `sendPasswordResetEmail()`
- `updateProfile()` (display name, photo URL)
- `delete()` (account deletion)
- `authStateChanges()` (stream)

### Firestore Structure
**Collection:** `users/{uid}`

| Field | Type | Description |
|-------|------|-------------|
| `uid` | String | Firebase Auth UID |
| `email` | String | User email |
| `displayName` | String | User's display name |
| `phoneNumber` | String? | Optional phone number |
| `photoURL` | String? | Profile photo URL |
| `role` | String | `customer`, `rider`, `seller`, `admin` |
| `isEmailVerified` | bool | Email verification status |
| `createdAt` | Timestamp | Account creation time |
| `updatedAt` | Timestamp | Last profile update |
| `lastLoginAt` | Timestamp | Last login time |
| `isActive` | bool | Account active status |
| `fcmTokens` | List<String> | FCM push notification tokens |

### Cloud Function (Expected)
**Trigger:** `onCreate` user document creation
- Creates user document in Firestore after Firebase Auth registration
- Sets default role to `customer`
- Initializes timestamps

---

## 🎨 UI Components (Shared Widgets)

Located in `packages/core/lib/widgets/`:

| Widget | Purpose |
|--------|---------|
| `AuthTextField` | Reusable text field with validation |
| `PasswordTextField` | Password field with visibility toggle |
| `PrimaryButton` | Primary action button with loading state |
| `SecondaryButton` | Outlined button with loading state |
| `SocialLoginButton` | Google/Apple Sign-In button |
| `LoadingOverlay` | Full-screen loading spinner |
| `LoadingIndicator` | Simple loading indicator |
| `AuthErrorMessage` | Error message display |

Located in `packages/auth/lib/presentation/widgets/`:

| Widget | Purpose |
|--------|---------|
| `AuthHeader` | Reusable header for auth screens |
| `PasswordStrengthIndicator` | Password strength visualization |

### Form Validation (in `packages/core/lib/utils/validators.dart`)
- `Validators.email` → Validates email format
- `Validators.password` → Min 6 chars, requires uppercase, lowercase, digit
- `Validators.strongPassword` → Enhanced password validation
- `Validators.name` → Name validation
- `Validators.required` → Non-empty validation
- `Validators.confirmPassword` → Match password confirmation

---

## 🎨 Theming

**Theme Config:** `packages/core/lib/theme/app_theme.dart`

- **Light Theme:** `AppTheme.lightTheme`
- **Dark Theme:** `AppTheme.darkTheme`
- **Current Mode:** `ThemeMode.light` (configured in each app's `main.dart`)

### App Constants
**File:** `packages/core/lib/constants/app_constants.dart`
- `AppDimens` - Spacing, padding, border radius values
- `AppColors` - Color palette (should be used instead of hardcoded colors)

**Example fix in `apps/customer_app/lib/main.dart`:**
```dart
// Before (hardcoded):
color: Colors.red,

// After (using theme):
color: AppColors.error,
```

---

## ⚠️ Error Handling

### Result Pattern (in `packages/core/lib/errors/`)
```dart
// Success case
Result<UserModel>.success(userModel);

// Failure case
Result<UserModel>.failure(AuthFailure.invalidEmail());
```

### Failure Types (in `packages/core/lib/errors/failure.dart`)
- `AuthFailure.invalidEmail()`
- `AuthFailure.weakPassword()`
- `AuthFailure.emailAlreadyInUse()`
- `AuthFailure.wrongPassword()`
- `AuthFailure.userNotFound()`
- `AuthFailure.userDisabled()`
- `AuthFailure.tooManyRequests()`
- `AuthFailure.networkError()`
- `AuthFailure.invalidCredential()`
- `AuthFailure.unknown(message)`

### Error Mapping (in `packages/auth/lib/data/datasources/auth_datasource.dart`)
Firebase `FirebaseAuthException` codes are mapped to `AuthFailure` types via `_mapFirebaseAuthException()`.

---

## 🔒 Security Rules (Reference)

**File:** `firestore.rules` (root of repo)

```javascript
// Users can read/write their own document
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

**Storage Rules:** `storage.rules`
- Authenticated users can upload files to `users/{uid}/` path

---

## 📝 Conventions for Future Changes

### ✅ DO:
1. **Add new auth methods** in `AuthDataSource` interface (in `packages/auth/`) → implement in `AuthDataSourceImpl`
2. **Add new state** in `AuthState` class → update `AuthNotifier` (in `packages/auth/`)
3. **Add new providers** using `@riverpod` annotation → run `flutter pub run build_runner build --delete-conflicting-outputs` in `packages/auth/`
4. **Use shared widgets** from `packages/core/lib/widgets/` and `packages/auth/lib/presentation/widgets/`
5. **Handle errors** using `Result<T>` pattern (success/failure) from `packages/core/`
6. **Validate forms** using `Validators` class from `packages/core/lib/utils/`
7. **Update Firestore** user document when profile changes
8. **Use `AppColors`** and `AppDimens` from `packages/core/lib/constants/`
9. **Import from packages** using `package:fast_delivery_core/...` and `package:fast_delivery_auth/...`

### ❌ DON'T:
1. **Don't put business logic in UI** (screens/widgets) - use `AuthNotifier` in `packages/auth/`
2. **Don't call Firebase directly from UI** - go through providers
3. **Don't bypass `AuthNotifier`** - always use the notifier for state changes
4. **Don't hardcode colors/spacing** - use theme constants from `packages/core/`
5. **Don't forget to dispose** `TextEditingController` and `FocusNode` in State
6. **Don't skip error handling** - always handle `Result.failure` cases
7. **Don't duplicate code** - use shared packages instead of copying to individual apps

---

## 🔄 How to Modify This Feature

### Adding a New Auth Method (e.g., Apple Sign-In)
1. Add method to `AuthDataSource` interface (in `packages/auth/lib/data/datasources/auth_datasource.dart`)
2. Implement in `AuthDataSourceImpl` (same file)
3. Add method to `AuthRepository` interface (in `packages/auth/lib/data/repositories/auth_repository.dart`)
4. Implement in `AuthRepositoryImpl` (same file)
5. Add method to `AuthNotifier` (in `packages/auth/lib/domain/providers/auth_providers.dart`)
6. Update `AuthState` if needed (same file)
7. Create UI button/widget if needed (in `packages/auth/lib/presentation/widgets/` or `packages/core/lib/widgets/`)
8. **Update this doc** with new flow

### Adding a New Screen (e.g., Forgot Password Screen)
1. Create screen in `packages/auth/lib/presentation/screens/`
2. Add route to `_router` in each app's `main.dart` (e.g., `apps/customer_app/lib/main.dart`)
3. Use existing shared widgets from `packages/core/lib/widgets/` and `packages/auth/lib/presentation/widgets/`
4. Call appropriate `AuthNotifier` method
5. **Update this doc** with new route

### Changing User Model
1. Update `UserModel` (Freezed) in `packages/auth/lib/data/models/user_model.dart`
2. Run `build_runner` in `packages/auth/`: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update Firestore mapping in `AuthDataSourceImpl` (in `packages/auth/`)
4. Update Cloud Function if needed
5. **Update this doc** with new fields

---

## 🧪 Testing (TODO)

**Current Test:** `test/widget_test.dart` - Basic smoke test  
**Future Tests Needed:**
- Unit tests for `AuthNotifier` (in `packages/auth/`)
- Unit tests for `AuthDataSourceImpl` (in `packages/auth/`)
- Widget tests for `LoginScreen`, `RegisterScreen` (in `packages/auth/`)
- Integration tests for auth flows
- Tests should be added to each app's test directory (e.g., `apps/customer_app/test/`)

---

## 📦 Dependencies (in `packages/auth/pubspec.yaml` and `packages/core/pubspec.yaml`)

### Core Package (`packages/core/pubspec.yaml`)
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod code gen |
| `go_router` | ^14.8.1 | Navigation |
| `freezed_annotation` | ^3.0.0 | Immutable models |
| `json_annotation` | ^4.9.0 | JSON serialization |
| `firebase_core` | ^3.13.0 | Firebase core |
| `firebase_auth` | ^5.5.4 | Firebase Authentication |
| `cloud_firestore` | ^5.6.7 | Firestore database |
| `firebase_storage` | ^12.4.4 | Firebase Storage |
| `google_sign_in` | ^6.2.1 | Google Sign-In |
| `shared_preferences` | ^2.5.3 | Local storage |
| `intl` | ^0.20.2 | Internationalization |

### Auth Package (`packages/auth/pubspec.yaml`)
Depends on `fast_delivery_core` and adds:
| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.8.0 | Networking (for future API calls) |

### Apps (`apps/*/pubspec.yaml`)
Each app depends on both packages:
```yaml
dependencies:
  # Shared packages
  fast_delivery_core:
    path: ../../packages/core
  fast_delivery_auth:
    path: ../../packages/auth
  
  # Direct imports (already in core package, but needed for direct imports)
  flutter_riverpod: ^2.6.1
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.4
  # ... etc.
```

---

## 🚀 Quick Reference for AI Agents

**When modifying auth feature, always:**
1. Read this file first (`docs/auth_feature.md`)
2. Follow the Clean Architecture layers (data → domain → presentation) in `packages/auth/`
3. Use shared widgets from `packages/core/lib/widgets/` and `packages/auth/lib/presentation/widgets/`
4. Use Riverpod providers (not direct Firebase calls in UI)
5. Handle errors with `Result<T>` pattern from `packages/core/lib/errors/`
6. Update this doc after making changes
7. Run `flutter pub run build_runner build --delete-conflicting-outputs` in `packages/auth/` after changing providers/models
8. Import from packages using `package:fast_delivery_core/...` and `package:fast_delivery_auth/...`

**Key Files to Review:**
- `packages/auth/lib/data/datasources/auth_datasource.dart` - Firebase operations
- `packages/auth/lib/domain/providers/auth_providers.dart` - State management
- `packages/auth/lib/presentation/screens/login_screen.dart` - Login UI
- `packages/core/lib/theme/app_theme.dart` - Theming (AppColors, AppDimens)
- `packages/core/lib/utils/validators.dart` - Form validation
- Each app's `main.dart` (e.g., `apps/customer_app/lib/main.dart`) - Router configuration

**Common Pitfalls:**
- Forgetting to run `build_runner` in `packages/auth/` after provider changes
- Not disposing controllers in State classes
- Bypassing `AuthNotifier` and calling repos directly from UI
- Hardcoding colors instead of using `AppColors` from `packages/core/`
- Forgetting to update `pubspec.yaml` in packages when adding dependencies
- Not importing from packages correctly (`package:fast_delivery_core/...` vs local paths)

---

## 📦 Package Structure Summary

```
fast-delivery/
├── packages/
│   ├── core/                          # Shared core modules
│   │   ├── lib/
│   │   │   ├── constants/              # AppConstants, AppDimens, AppColors
│   │   │   ├── errors/                 # Failure, Result types
│   │   │   ├── firebase/               # Firebase options
│   │   │   ├── theme/                  # AppTheme (light/dark)
│   │   │   ├── utils/                  # Validators
│   │   │   └── widgets/               # Reusable widgets
│   │   └── pubspec.yaml
│   │
│   └── auth/                          # Shared auth feature
│       ├── lib/
│       │   ├── data/                   # Data layer
│       │   ├── domain/                 # Domain layer
│       │   └── presentation/           # Presentation layer
│       └── pubspec.yaml
│
├── apps/
│   ├── customer_app/      → uses fast_delivery_core + fast_delivery_auth
│   ├── seller_app/        → uses fast_delivery_core + fast_delivery_auth
│   ├── rider_app/         → uses fast_delivery_core + fast_delivery_auth
│   └── admin_panel/       → uses fast_delivery_core + fast_delivery_auth
│
└── docs/
    └── auth_feature.md    ← This documentation file
```

**End of Auth Feature Specification**
