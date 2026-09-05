import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maid_rent/models/user_model.dart';
import 'package:maid_rent/services/auth_service.dart';
import 'package:maid_rent/services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get initialized => _initialized;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      _userModel = await _firestoreService.getUser(user.uid);
    } else {
      _userModel = null;
    }
    _initialized = true;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Email & Password Sign Up
  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      await _authService.updateDisplayName(name);

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: UserRole.household, // Default, will be changed in role selection
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(user);
      _userModel = user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Email & Password Sign In
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      await _authService.signInWithEmail(email: email, password: password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      final credential = await _authService.signInWithGoogle();
      if (credential == null) {
        _setLoading(false);
        return false;
      }

      // Check if user already exists
      final existingUser =
          await _firestoreService.getUser(credential.user!.uid);
      if (existingUser == null) {
        final user = UserModel(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          profileImage: credential.user!.photoURL ?? '',
          role: UserRole.household,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(user);
        _userModel = user;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Google sign in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Facebook Sign In
  Future<bool> signInWithFacebook() async {
    try {
      _setLoading(true);
      final credential = await _authService.signInWithFacebook();
      if (credential == null) {
        _setLoading(false);
        return false;
      }

      final existingUser =
          await _firestoreService.getUser(credential.user!.uid);
      if (existingUser == null) {
        final user = UserModel(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? '',
          email: credential.user!.email ?? '',
          profileImage: credential.user!.photoURL ?? '',
          role: UserRole.household,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(user);
        _userModel = user;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Facebook sign in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Update user role
  Future<void> updateUserRole(UserRole role) async {
    if (_firebaseUser == null) return;
    await _firestoreService.updateUser(_firebaseUser!.uid, {'role': role.name});
    _userModel = _userModel?.copyWith(role: role);
    notifyListeners();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (_firebaseUser == null) return;
    _userModel = await _firestoreService.getUser(_firebaseUser!.uid);
    notifyListeners();
  }

  // Password reset
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to send reset email. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  String _getAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
