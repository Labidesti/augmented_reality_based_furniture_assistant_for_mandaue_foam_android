// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'login_screen.dart';
import 'admin_home_screen.dart';
import 'customer_home_screen.dart';
import 'verify_email_screen.dart'; // <-- IMPORT THE NEW SCREEN

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

          // NEW LOGIC: Check if the user's email is verified
          if (user != null) {
            if (user.emailVerified) {
              // If verified, check if they are an admin or customer
              if (user.email == adminEmail) {
                return const AdminHomeScreen();
              } else {
                return const CustomerHomeScreen();
              }
            } else {
              // If not verified, show the verification screen
              return const VerifyEmailScreen();
            }
          }
        }

        // If no user is logged in, show the Login Screen
        return const LoginScreen();
      },
    );
  }
}