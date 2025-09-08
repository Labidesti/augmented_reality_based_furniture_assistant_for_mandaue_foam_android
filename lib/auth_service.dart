// lib/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // 🔹 Stream of auth state changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // 🔹 Current user
  User? get currentUser => _auth.currentUser;

  /// Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuth error [${e.code}]: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      return null;
    }
  }

  /// Email + password sign up
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCred.user?.sendEmailVerification();
      return userCred;
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign up error [${e.code}]: ${e.message}");
      rethrow;
    }
  }

  /// Email + password login
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Sign in error [${e.code}]: ${e.message}");
      rethrow;
    }
  }

  /// Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint("Password reset error [${e.code}]: ${e.message}");
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // only if Google login
    } catch (_) {
      // ignore if not Google login
    }
    await _auth.signOut();
  }
}
