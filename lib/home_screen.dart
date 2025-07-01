// lib/home_screen.dart

import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    // Use our centralized service to sign out
    await AuthService().signOut();
    // No need for navigation, the AuthWrapper will handle it!
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Logged in as:\n${user?.email ?? "Unknown User"}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}