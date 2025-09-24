import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/verify_email_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/customer_home_screen.dart';
import 'screens/ar_view_screen.dart';
import 'screens/ai_assistant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AR Furniture Assistant",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // ✅ First screen when app launches
      initialRoute: "/",

      routes: {
        "/": (context) => const LoginScreen(),
        "/signup": (context) => const SignupScreen(),
        "/verify-email": (context) => const VerifyEmailScreen(),
        "/forgot-password": (context) => const ForgotPasswordScreen(),
        "/admin": (context) => const AdminHomeScreen(),
        "/customer": (context) => const CustomerHomeScreen(),
        "/ar": (context) => const ArViewScreen(),
        "/ai": (context) => const AiAssistantScreen(),
      },
    );
  }
}
