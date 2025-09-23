import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/screens/tutorial_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'services/firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/ar_view_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // check first launch
  final prefs = await SharedPreferences.getInstance();
  final seenTutorial = prefs.getBool('seenTutorial') ?? false;

  runApp(MyApp(seenTutorial: seenTutorial));
}

class MyApp extends StatelessWidget {
  final bool seenTutorial;
  const MyApp({super.key, required this.seenTutorial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Furniture Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: seenTutorial ? '/login' : '/tutorial',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/tutorial': (context) => const TutorialScreen(),
        '/customer': (context) => const CustomerHomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/verify': (context) => const VerifyEmailScreen(),
        '/admin': (context) => const AdminHomeScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/ar': (context) => const ArViewScreen(), // ✅ AR route added
      },
    );
  }
}

/// Handles auth state & redirects
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) return const LoginScreen();

        final user = snapshot.data!;
        if (!user.emailVerified) return const VerifyEmailScreen();

        if (user.email?.endsWith("@mandauefoam.ph") ?? false) {
          return const AdminHomeScreen();
        } else {
          return const CustomerHomeScreen();
        }
      },
    );
  }
}
