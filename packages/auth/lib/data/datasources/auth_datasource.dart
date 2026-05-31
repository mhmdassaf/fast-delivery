import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fast_delivery_core/errors/failure.dart';
import 'package:fast_delivery_core/errors/result.dart';
import '../models/user_model.dart';

/// Data source interface for authentication operations
abstract class AuthDataSource {
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

/// Implementation of AuthDataSource using Firebase
class AuthDataSourceImpl implements AuthDataSource {
  final firebase_auth.FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthDataSourceImpl({
    firebase_auth.FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        // Only set clientId for web; mobile platforms use their native config
        _googleSignIn = googleSignIn ??
            (kIsWeb
                ? GoogleSignIn(
                    clientId:
                        '130528704034-t5q7dhu407p9c46a9f5qqjo82uqu2i0i.apps.googleusercontent.com',
                    scopes: ['email', 'profile'],
                  )
                : GoogleSignIn(scopes: ['email', 'profile'])),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _mapFirebaseUserToUserModel(firebaseUser);
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _mapFirebaseUserToUserModel(firebaseUser);
  }

  @override
  Future<Result<UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(AuthFailure.unknown('Login failed'));
      }

      // Update last login in Firestore
      await _updateLastLogin(credential.user!.uid);

      // Fetch user document from Firestore to get role and other data
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // User document doesn't exist, create one with defaults
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: credential.user!.displayName ?? '',
          photoURL: credential.user!.photoURL,
          role: UserRole.customer,
          isEmailVerified: credential.user!.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isActive: true,
          phoneNumber: credential.user!.phoneNumber,
          fcmTokens: const [],
        );
        await _createUserDocument(userModel);
        return Result.success(userModel);
      }

      // Return user model from Firestore
      final userData = userDoc.data()!;
      return Result.success(
        UserModel(
          uid: credential.user!.uid,
          email: userData['email'] ?? email,
          displayName: userData['displayName'] ?? credential.user!.displayName ?? '',
          phoneNumber: userData['phoneNumber'] ?? credential.user!.phoneNumber,
          photoURL: userData['photoURL'] ?? credential.user!.photoURL,
          role: _parseRole(userData['role']),
          isEmailVerified: userData['emailVerified'] ?? credential.user!.emailVerified,
          createdAt: _parseDateTime(userData['createdAt']) ?? DateTime.now(),
          updatedAt: _parseDateTime(userData['updatedAt']),
          lastLoginAt: _parseDateTime(userData['lastLoginAt']),
          isActive: userData['isActive'] ?? true,
          fcmTokens: List<String>.from(userData['fcmTokens'] ?? []),
        ),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Sign in failed'));
    }
  }

  @override
  Future<Result<UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    UserRole role = UserRole.customer,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return Result.failure(AuthFailure.unknown('Registration failed'));
      }

      // Update display name
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user!.updateDisplayName(displayName);
      }

      // Create the user document immediately with the correct role.
      // The Cloud Function (auth.user().onCreate()) also fires asynchronously,
      // but it already has an idempotency guard — if the doc exists, it skips.
      // This ensures the correct role is always set, regardless of which app
      // the user registered from.
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName ?? '',
        photoURL: null,
        role: role,
        isEmailVerified: credential.user!.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        phoneNumber: null,
        fcmTokens: const [],
      );
      await _createUserDocument(userModel);

      return Result.success(userModel);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Registration failed'));
    }
  }

  @override
  Future<Result<UserModel>> signInWithGoogle({
    UserRole role = UserRole.customer,
  }) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Result.failure(AuthFailure.unknown('Google sign-in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final credentialResult =
          await _auth.signInWithCredential(credential);

      if (credentialResult.user == null) {
        return Result.failure(AuthFailure.unknown('Google sign-in failed'));
      }

      // Check if user exists in Firestore, if not create with the correct role
      final userExists = await _checkUserExists(credentialResult.user!.uid);
      if (!userExists) {
        final userModel = UserModel.fromFirebaseAuth(
          uid: credentialResult.user!.uid,
          email: credentialResult.user!.email ?? '',
          displayName: credentialResult.user!.displayName,
          photoURL: credentialResult.user!.photoURL,
          emailVerified: credentialResult.user!.emailVerified,
          role: role,
        );
        await _createUserDocument(userModel);
      } else {
        await _updateLastLogin(credentialResult.user!.uid);
      }

      return Result.success(
        _mapFirebaseUserToUserModel(credentialResult.user!),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Google sign-in failed'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Sign out failed'));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseAuthException(e));
    } catch (e) {
      return Result.failure(AuthFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Result<UserModel>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.failure(AuthFailure.unknown('No user logged in'));
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();

      // Update Firestore document
      await _updateUserDocument(user.uid, {
        'displayName': displayName,
        'photoURL': photoURL,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return Result.success(_mapFirebaseUserToUserModel(user));
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Profile update failed'));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.failure(AuthFailure.unknown('No user logged in'));
      }

      // Delete Firestore document first
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Account deletion failed'));
    }
  }

  @override
  Future<Result<UserModel>> reloadUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Result.failure(AuthFailure.unknown('No user logged in'));
      }

      await user.reload();
      return Result.success(_mapFirebaseUserToUserModel(user));
    } catch (e) {
      return Result.failure(AuthFailure.unknown('Reload user failed'));
    }
  }

  // Helper methods

  UserModel _mapFirebaseUserToUserModel(
    firebase_auth.User user, {
    bool isNew = false,
  }) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      phoneNumber: user.phoneNumber,
      photoURL: user.photoURL,
      role: UserRole.customer, // Default - will be updated from Firestore
      isEmailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: isNew ? DateTime.now() : user.metadata.lastSignInTime,
    );
  }

  Failure _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AuthFailure.invalidEmail();
      case 'weak-password':
        return AuthFailure.weakPassword();
      case 'email-already-in-use':
        return AuthFailure.emailAlreadyInUse();
      case 'wrong-password':
        return AuthFailure.wrongPassword();
      case 'user-not-found':
        return AuthFailure.userNotFound();
      case 'user-disabled':
        return AuthFailure.userDisabled();
      case 'too-many-requests':
        return AuthFailure.tooManyRequests();
      case 'network-error':
        return AuthFailure.networkError();
      case 'invalid-credential':
        return AuthFailure.invalidCredential();
      default:
        return AuthFailure.unknown(e.message);
    }
  }

  Future<void> _createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<void> _updateUserDocument(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _checkUserExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  /// Parse role from Firestore
  UserRole _parseRole(dynamic roleStr) {
    if (roleStr == null) return UserRole.customer;
    switch (roleStr.toString()) {
      case 'customer':
        return UserRole.customer;
      case 'rider':
        return UserRole.rider;
      case 'seller':
        return UserRole.seller;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  /// Parse DateTime from Firestore
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    // Handle Firestore Timestamp (properly)
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}