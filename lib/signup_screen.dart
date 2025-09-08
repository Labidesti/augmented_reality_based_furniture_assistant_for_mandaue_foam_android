// lib/signup_screen.dart

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'constants/app_constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  bool _isPasswordCompliant(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<void> _signUpUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showError("Please fill in all fields.");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showError("Passwords do not match.");
      return;
    }
    if (!_isPasswordCompliant(passwordController.text)) {
      _showError(
          'Password must be 8+ characters with an uppercase letter, a number, and a special character.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError("Failed to create account: ${e.toString()}");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError("Failed to sign in with Google: ${e.toString()}");
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 32.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(mandaueFoamLogo, height: 180),
                      const SizedBox(height: 30),
                      const Text('Create Account', textAlign: TextAlign.center,
                          style: headingStyle),
                      const SizedBox(height: 8),
                      const Text('Create an account to get started!',
                          textAlign: TextAlign.center, style: subheadingStyle),
                      const SizedBox(height: 30),

                      // 📧 Email
                      TextFormField(
                        controller: emailController,
                        decoration: _inputDecoration("Email"),
                      ),
                      const SizedBox(height: 20),

                      // 🔑 Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: _inputDecoration("Password").copyWith(
                          helperText:
                          '8+ characters, 1 uppercase, 1 number, 1 special character',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: hintTextColor,
                            ),
                            onPressed: () =>
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔑 Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: _inputDecoration("Confirm Password")
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: hintTextColor,
                            ),
                            onPressed: () =>
                                setState(() {
                                  _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                                }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔵 Sign Up button
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        ...[
                          ElevatedButton(
                            onPressed: _signUpUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(60),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                                'Sign up', style: buttonTextStyle),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('Or continue with',
                                    style: TextStyle(color: hintTextColor)),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 🟢 Google Sign In Button
                          ElevatedButton.icon(
                            onPressed: _loginWithGoogle,
                            icon: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(googleLogo),
                            ),
                            label: const Text(
                              'Sign up with Google',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: googleButtonColor,
                              minimumSize: const Size.fromHeight(55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],

                      const Spacer(),
                      // ✅ Pushes content upward if screen is taller
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Helper to reduce duplication
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding:
      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
  }
}