// lib/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  // ✅ Auth state changes stream (fixes main.dart error)
  Stream<User?> get userChanges => _auth.authStateChanges();

  // ✅ Currently logged-in user
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      return null;
    }
  }

  /// Email + password sign up
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCred.user?.sendEmailVerification();
    return userCred;
  }

  /// Email + password login
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut(); // only works if user signed in with Google
    } catch (_) {
      // ignore if not a Google login
    }
    await _auth.signOut(); // always sign out from Firebase
  }
}