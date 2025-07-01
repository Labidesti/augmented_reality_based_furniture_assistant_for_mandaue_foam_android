// lib/main.dart

import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/auth_service.dart';
import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/home_screen.dart';
import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- ADD THIS LINE

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      // Hides the debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use the AuthWrapper to listen for auth state changes
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // Listen to the user stream from our AuthService
      stream: authService.user,
      builder: (context, snapshot) {
        // If the connection is still waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the snapshot has data, it means the user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Otherwise, the user is not logged in
        return const LoginScreen();
      },
    );
  }
}