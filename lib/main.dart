// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'login_screen.dart';
import 'admin_home_screen.dart'; // Import admin screen
import 'customer_home_screen.dart'; // Import customer screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Furniture Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  // !!! IMPORTANT: Change this to your actual admin email address !!!
  static const String adminEmail = 'admin@mandauefoam.com';

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data;
          // Check if the logged-in user is an admin
          if (user != null && user.email == adminEmail) {
            // If yes, show the Admin Home Screen
            return const AdminHomeScreen();
          } else {
            // Otherwise, show the Customer Home Screen
            return const CustomerHomeScreen();
          }
        }

        // If no user is logged in, show the Login Screen
        return const LoginScreen();
      },
    );
  }
}