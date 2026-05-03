# Auth Feature Specification

> **AI-Readable Documentation for Auth Feature**  
> **Last Updated:** 2026-05-03  
> **Feature Status:** ✅ Implemented  
> **Commit:** `b556f35` - refactor(user_app): restructure app with Clean Architecture and Firebase authentication

---

## 📋 Feature Overview

**Purpose:** User authentication system for the Fast Delivery User App  
**Scope:** Login, Registration, Password Reset, Google Sign-In, Auth State Management  
**Roles Supported:** `user` (default), `rider`, `seller`, `admin`  
**Platform:** Flutter (iOS, Android, Web)

---

## 🏗️ Architecture (Clean Architecture + MVVM)

### Layer Structure
```
lib/features/auth/
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

### Key Principles
- **Data Layer:** Handles Firebase Auth + Firestore operations via `AuthDataSource`
- **Domain Layer:** Contains business logic via Riverpod `AuthNotifier` and repository interfaces
- **Presentation Layer:** UI components (screens, widgets) that consume providers

---

## 🔐 Authentication Flows

### 1. Email/Password Login
**Entry Point:** `login_screen.dart` → `_handleSignIn()`
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
**Entry Point:** `register_screen.dart` → `_handleSignUp()`
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
**Entry Point:** `login_screen.dart` or `register_screen.dart` → `_handleGoogleSignIn()`
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
**Entry Point:** `login_screen.dart` → `_handleForgotPassword()`
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

### Providers (in `auth_providers.dart`)

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

**Router Config:** Defined in `main.dart` → `_router`

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | `AuthGate` | **Smart router** - redirects based on auth state |
| `/login` | `LoginScreen` | Email/password login + Google Sign-In |
| `/register` | `RegisterScreen` | New user registration |

### AuthGate Logic
```dart
// In auth_gate.dart
final authStatus = ref.watch(authStatusProvider);

if (authStatus == AuthStatus.authenticated) {
  return HomeScreen(); // TODO: Implement home screen
} else {
  return LoginScreen(); // Redirect to login
}
```

---

## 🔥 Firebase Integration

### Firebase Auth Methods Used
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
| `role` | String | `user`, `rider`, `seller`, `admin` |
| `isEmailVerified` | bool | Email verification status |
| `createdAt` | Timestamp | Account creation time |
| `updatedAt` | Timestamp | Last profile update |
| `lastLoginAt` | Timestamp | Last login time |
| `isActive` | bool | Account active status |
| `fcmTokens` | List<String> | FCM push notification tokens |

### Cloud Function (Expected)
**Trigger:** `onCreate` user document creation
- Creates user document in Firestore after Firebase Auth registration
- Sets default role to `user`
- Initializes timestamps

---

## 🎨 UI Components (Shared Widgets)

Located in `lib/shared/widgets/`:

| Widget | Purpose |
|--------|---------|
| `AuthTextField` | Reusable text field with validation |
| `PasswordTextField` | Password field with visibility toggle |
| `PrimaryButton` | Primary action button with loading state |
| `SocialLoginButton` | Google Sign-In button |
| `LoadingOverlay` | Full-screen loading spinner |
| `AuthErrorMessage` | Error message display |

### Form Validation (in `core/utils/validators.dart`)
- `Validators.email` → Validates email format
- `Validators.password` → Min 6 chars, requires uppercase, lowercase, digit
- `Validators.required` → Non-empty validation
- `Validators.confirmPassword` → Match password confirmation

---

## 🎨 Theming

**Theme Config:** `core/theme/app_theme.dart`

- **Light Theme:** `AppTheme.lightTheme`
- **Dark Theme:** `AppTheme.darkTheme`
- **Current Mode:** `ThemeMode.light` (configured in `main.dart`)

### App Constants
**File:** `core/constants/app_constants.dart`
- `AppDimens` - Spacing, padding, border radius values
- `AppColors` - Color palette (should be used instead of hardcoded colors)

---

## ⚠️ Error Handling

### Result Pattern (in `core/errors/`)
```dart
// Success case
Result<UserModel>.success(userModel);

// Failure case
Result<UserModel>.failure(AuthFailure.invalidEmail());
```

### Failure Types (in `core/errors/failure.dart`)
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

### Error Mapping (in `auth_datasource.dart`)
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
1. **Add new auth methods** in `AuthDataSource` interface → implement in `AuthDataSourceImpl`
2. **Add new state** in `AuthState` class → update `AuthNotifier`
3. **Add new providers** using `@riverpod` annotation → run `flutter pub run build_runner build --delete-conflicting-outputs`
4. **Use shared widgets** (`AuthTextField`, `PrimaryButton`) for consistency
5. **Handle errors** using `Result<T>` pattern (success/failure)
6. **Validate forms** using `Validators` class before submission
7. **Update Firestore** user document when profile changes
8. **Use `AppColors`** and `AppDimens` instead of hardcoded values

### ❌ DON'T:
1. **Don't put business logic in UI** (screens/widgets) - use `AuthNotifier`
2. **Don't call Firebase directly from UI** - go through providers
3. **Don't bypass `AuthNotifier`** - always use the notifier for state changes
4. **Don't hardcode colors/spacing** - use theme constants
5. **Don't forget to dispose** `TextEditingController` and `FocusNode` in State
6. **Don't skip error handling** - always handle `Result.failure` cases

---

## 🔄 How to Modify This Feature

### Adding a New Auth Method (e.g., Apple Sign-In)
1. Add method to `AuthDataSource` interface
2. Implement in `AuthDataSourceImpl`
3. Add method to `AuthRepository` interface
4. Implement in `AuthRepositoryImpl`
5. Add method to `AuthNotifier`
6. Update `AuthState` if needed
7. Create UI button/widget if needed
8. **Update this doc** with new flow

### Adding a New Screen (e.g., Forgot Password Screen)
1. Create screen in `presentation/screens/`
2. Add route to `_router` in `main.dart`
3. Use existing shared widgets
4. Call appropriate `AuthNotifier` method
5. **Update this doc** with new route

### Changing User Model
1. Update `UserModel` (Freezed) in `data/models/user_model.dart`
2. Run `build_runner` to regenerate `user_model.g.dart`
3. Update Firestore mapping in `AuthDataSourceImpl`
4. Update Cloud Function if needed
5. **Update this doc** with new fields

---

## 🧪 Testing (TODO)

**Current Test:** `test/widget_test.dart` - Basic smoke test  
**Future Tests Needed:**
- Unit tests for `AuthNotifier`
- Unit tests for `AuthDataSourceImpl`
- Widget tests for `LoginScreen`, `RegisterScreen`
- Integration tests for auth flows

---

## 📦 Dependencies (in `pubspec.yaml`)

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_auth` | ^5.3.1 | Firebase Authentication |
| `google_sign_in` | ^6.2.1 | Google Sign-In |
| `cloud_firestore` | ^5.6.7 | Firestore database |
| `flutter_riverpod` | ^2.6.1 | State management |
| `riverpod_annotation` | ^2.6.1 | Riverpod code gen |
| `go_router` | ^14.8.2 | Navigation |
| `freezed_annotation` | ^3.0.0 | Immutable models |

---

## 🚀 Quick Reference for AI Agents

**When modifying auth feature, always:**
1. Read this file first (`docs/auth_feature.md`)
2. Follow the Clean Architecture layers (data → domain → presentation)
3. Use Riverpod providers (not direct Firebase calls in UI)
4. Handle errors with `Result<T>` pattern
5. Update this doc after making changes
6. Run `flutter pub run build_runner build --delete-conflicting-outputs` after changing providers/models

**Key Files to Review:**
- `lib/features/auth/data/datasources/auth_datasource.dart` - Firebase operations
- `lib/features/auth/domain/providers/auth_providers.dart` - State management
- `lib/features/auth/presentation/screens/login_screen.dart` - Login UI
- `lib/main.dart` - Router configuration

**Common Pitfalls:**
- Forgetting to run `build_runner` after provider changes
- Not disposing controllers in State classes
- Bypassing `AuthNotifier` and calling repos directly from UI
- Hardcoding colors instead of using `AppColors`

---

**End of Auth Feature Specification**
