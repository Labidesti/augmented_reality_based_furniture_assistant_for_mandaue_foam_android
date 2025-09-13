import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// constants
import 'constants/admin_guard.dart';
import 'constants/app_constants.dart';

// firebase
import 'firebase_options.dart';

// screens
import 'login_screen.dart';
import 'signup_screen.dart';
import 'verify_email_screen.dart';
import 'customer_home_screen.dart';
import 'admin_home_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Mandaue Foam AR',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/verify': (context) => const VerifyEmailScreen(),
        '/customer': (context) => const CustomerHomeScreen(),
        '/admin': (context) => AdminGuard(
          child: const AdminHomeScreen(),
        ),
      },
    );
  }
}
