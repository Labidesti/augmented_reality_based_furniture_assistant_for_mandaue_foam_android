// lib/login_screen.dart

import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/auth_service.dart';
import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      // Navigation is now handled by AuthWrapper, so no need for Navigator.push
    } catch (e) {
      _showError("Failed to sign in: ${e.toString()}");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      // Navigation handled by AuthWrapper
    } catch (e) {
      _showError("Failed to sign in with Google: ${e.toString()}");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  ElevatedButton(
                    onPressed: _loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Log In'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _loginWithGoogle,
                    icon: Image.asset('assets/Google_Favicon_2025.png', height: 24),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text("Don’t have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}