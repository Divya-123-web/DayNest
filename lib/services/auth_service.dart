import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

/// An error with a message that is safe to show to the user.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Talks to Firebase Authentication.
/// The AuthProvider uses this class; screens never call it directly.
class AuthService {
  final FirebaseAuth _auth = FirebaseService.auth;

  /// Fires when someone logs in or out (and once when the app starts).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The signed-in user right now, or null.
  User? get currentUser => _auth.currentUser;

  /// Logs in with email and password.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  /// Creates a new account, sets the display name and saves a profile.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User user = credential.user!;
      await user.updateDisplayName(name.trim());
      await user.reload();

      // Save the profile document: users/{uid}.
      await _saveProfile(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        isNewUser: true,
      );

      return _auth.currentUser ?? user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  /// Sends a password reset email.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } catch (_) {
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  /// Logs out.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Changes the display name of the signed-in user.
  Future<User> updateDisplayName(String name) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('You are not logged in.');
    }

    try {
      await user.updateDisplayName(name.trim());
      await user.reload();

      await _saveProfile(
        uid: user.uid,
        name: name.trim(),
        email: user.email ?? '',
        isNewUser: false,
      );

      return _auth.currentUser ?? user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e.code));
    } catch (_) {
      throw const AuthException('Could not update your name.');
    }
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Saves the profile document (users/{uid}).
  /// If this fails, the account still works, so we only print the problem.
  Future<void> _saveProfile({
    required String uid,
    required String name,
    required String email,
    required bool isNewUser,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'uid': uid,
        'name': name,
        'email': email,
      };
      if (isNewUser) {
        data['createdAt'] = Timestamp.fromDate(DateTime.now());
      }

      await FirebaseService.userDoc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Could not save the profile: $e');
    }
  }

  /// Turns a Firebase error code into a friendly message.
  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled in Firebase yet.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}