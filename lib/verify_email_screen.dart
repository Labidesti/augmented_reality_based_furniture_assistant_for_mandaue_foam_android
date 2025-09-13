import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();

      // Poll every 3s to check verification
      timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send email: $e")),
      );
    }
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      setState(() => isEmailVerified = true);
      timer?.cancel();

      // Redirect based on role (basic: admin vs customer)
      if (!mounted) return;
      if (user.email?.endsWith("@mandauefoam.ph") ?? false) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/customer');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const Center(child: CircularProgressIndicator()) // while redirecting
        : Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              "A verification email has been sent to your inbox.\n"
                  "Please confirm your email address to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              child: const Text("Resend Email"),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("Cancel / Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
