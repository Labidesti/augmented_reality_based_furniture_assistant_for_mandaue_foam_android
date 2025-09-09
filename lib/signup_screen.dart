// lib/signup_screen.dart

import 'package:augmented_reality_based_furniture_assistant_for_mandaue_foam_android/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

  Future<void> _signUpUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      // Close the sign-up screen to go back to the AuthWrapper which will redirect
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError("Failed to create account: ${e.toString()}");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      // Navigation is now handled by AuthWrapper
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError("Failed to sign up with Google: ${e.toString()}");
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
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Updated to use the correct Mandaue Foam logo file name
                Image.asset('assets/mandauefoam_Logo.png', height: 100),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _signUpUser,
                    child: const Text("Sign Up", style: TextStyle(fontSize: 16)),
                  ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const SizedBox()
                else
                  ElevatedButton.icon(
                    onPressed: _signUpWithGoogle,
                    icon: Image.asset('assets/Google_Logo_2025.png', height: 24),
                    label: const Text('Sign up with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Just pop the screen to go back to the login screen
                    Navigator.of(context).pop();
                  },
                  child: const Text("Already have an account? Log in"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}