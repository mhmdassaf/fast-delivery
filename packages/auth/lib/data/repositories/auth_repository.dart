import 'package:fast_delivery_core/errors/result.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Gets the current authenticated user stream
  Stream<UserModel?> get authStateChanges;

  /// Gets the current authenticated user
  UserModel? get currentUser;

  /// Signs in with email and password
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Signs up with email and password
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.customer,
  });

  /// Signs in with Google
  Future<Result<UserModel>> signInWithGoogle({
    UserRole role = UserRole.customer,
  });

  /// Signs out the current user
  Future<Result<void>> signOut();

  /// Sends password reset email
  Future<Result<void>> sendPasswordResetEmail({required String email});

  /// Updates user profile
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoURL,
  });

  /// Deletes user account
  Future<Result<void>> deleteAccount();

  /// Reloads user data from Firebase
  Future<Result<UserModel>> reloadUser();
}

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl({required AuthDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Stream<UserModel?> get authStateChanges => _dataSource.authStateChanges;

  @override
  UserModel? get currentUser => _dataSource.currentUser;

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.customer,
  }) {
    return _dataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
  }

  @override
  Future<Result<UserModel>> signInWithGoogle({
    UserRole role = UserRole.customer,
  }) {
    return _dataSource.signInWithGoogle(role: role);
  }

  @override
  Future<Result<void>> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) {
    return _dataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoURL,
  }) {
    return _dataSource.updateProfile(
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  @override
  Future<Result<void>> deleteAccount() {
    return _dataSource.deleteAccount();
  }

  @override
  Future<Result<UserModel>> reloadUser() {
    return _dataSource.reloadUser();
  }
}