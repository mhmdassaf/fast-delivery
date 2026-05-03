import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/auth_datasource.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

// ============================================================================
// Data Sources
// ============================================================================

/// Firebase Auth instance provider
@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

/// Auth data source provider
@riverpod
AuthDataSource authDataSource(Ref ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthDataSourceImpl(auth: auth);
}

// ============================================================================
// Repositories
// ============================================================================

/// Auth repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
}

// ============================================================================
// Auth State Stream
// ============================================================================

/// Auth state changes stream provider
@riverpod
Stream<UserModel?> authStateChanges(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

/// Current user provider (synchronous)
@riverpod
UserModel? currentUser(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.currentUser;
}

// ============================================================================
// Authentication Status
// ============================================================================

/// Authentication status enum
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

/// Auth status based on auth state stream
@riverpod
AuthStatus authStatus(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    loading: () => AuthStatus.initial,
    error: (_, __) => AuthStatus.unauthenticated,
  );
}

// ============================================================================
// Auth Notifier (State Management)
// ============================================================================

/// State class for authentication
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isAuthenticated => user != null;
}

/// Auth notifier for managing authentication state
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    // Listen to auth state changes
    ref.listen<AsyncValue<UserModel?>>(
      authStateChangesProvider,
      (previous, next) {
        next.whenData((user) {
          state = state.copyWith(user: user);
        });
      },
    );

    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signInWithGoogle();

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Sign out
  Future<bool> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signOut();

    return result.fold(
      onSuccess: (_) {
        state = const AuthState();
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.sendPasswordResetEmail(email: email);

    return result.fold(
      onSuccess: (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    return result.fold(
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}