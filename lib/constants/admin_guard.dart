import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  bool _isAdmin(User? user) {
    if (user == null) return false;
    // ✅ Simple role check: company domain
    return user.email?.endsWith("@mandauefoam.ph") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → redirect to login
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!user.emailVerified) {
      // Not verified → redirect to verify screen
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/verify');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin(user)) {
      // Not admin → redirect to customer home
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/customer');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Passed all checks → show admin page
    return child;
  }
}
