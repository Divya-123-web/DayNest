import 'dart:async';

import 'package:daynest/screens/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

/// Holds the signed-in user and the login / register / logout actions.
/// It uses Firebase Authentication through AuthService.
/// Screens only talk to this provider.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    // Firebase tells us whenever someone logs in or out.
    // It also tells us once at app start, so we know if the user
    // was already signed in from last time.
    _subscription = _service.authStateChanges.listen(
      _onAuthChanged,
      onError: (Object error) {
        debugPrint('Auth state error: $error');
        _isInitialized = true;
        notifyListeners();
      },
    );
  }

  final AuthService _service = AuthService();
  StreamSubscription<User?>? _subscription;

  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  /// The signed-in user, or null when logged out.
  UserModel? get user => _user;

  bool get isLoggedIn => _user != null;

  /// True while a login / register / reset is running.
  bool get isLoading => _isLoading;

  /// False until Firebase has told us if someone is already signed in.
  /// The splash screen waits for this before choosing the next screen.
  bool get isInitialized => _isInitialized;

  /// The last error message (for example "Incorrect email or password."),
  /// or null.
  String? get errorMessage => _errorMessage;

  /// Logs in. Returns true on success.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final User firebaseUser = await _service.login(
        email: email,
        password: password,
      );
      _user = _toUserModel(firebaseUser);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    }
  }

  /// Creates an account and logs in. Returns true on success.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final User firebaseUser = await _service.register(
        name: name,
        email: email,
        password: password,
      );
      _user = _toUserModel(firebaseUser);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    }
  }

  /// Sends a password reset email. Returns true on success.
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _service.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _fail(e.message);
      return false;
    }
  }

  /// Logs out.
  Future<void> logout() async {
    await _service.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Changes the display name of the signed-in user.
  /// The screen updates right away; if saving fails, the old name returns.
  Future<void> updateName(String newName) async {
    final UserModel? previous = _user;
    if (previous == null) return;

    // Show the new name immediately.
    _user = previous.copyWith(name: newName.trim());
    notifyListeners();

    try {
      final User updated = await _service.updateDisplayName(newName);
      _user = _toUserModel(updated);
      notifyListeners();
    } on AuthException catch (e) {
      // Saving failed: go back to the old name.
      _user = previous;
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Clears the last error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Called by Firebase when someone logs in or out.
  void _onAuthChanged(User? firebaseUser) {
    _user = firebaseUser == null ? null : _toUserModel(firebaseUser);
    _isInitialized = true;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _errorMessage = null;
    notifyListeners();
  }

  void _fail(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Turns a Firebase user into our own UserModel.
  UserModel _toUserModel(User firebaseUser) {
    final String email = firebaseUser.email ?? '';
    final String displayName = (firebaseUser.displayName ?? '').trim();

    return UserModel(
      uid: firebaseUser.uid,
      name: displayName.isNotEmpty ? displayName : _nameFromEmail(email),
      email: email,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Used when the account has no name, e.g. "divya@x.com" -> "Divya".
  String _nameFromEmail(String email) {
    final String local = email.split('@').first.trim();
    if (local.isEmpty) return 'Friend';
    return local[0].toUpperCase() + local.substring(1);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}