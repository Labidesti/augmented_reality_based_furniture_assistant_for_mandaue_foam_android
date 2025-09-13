// lib/constants/app_constants.dart
import 'package:flutter/material.dart';

// App Colors
const Color primaryColor = Color(0xFF1F41BB);
const Color secondaryColor = Color(0xFFF1F4FF);
const Color backgroundColor = Color(0xFFF8F9FF);
const Color googleButtonColor = Color(0xFF4385F5);
const Color textColor = Colors.black;
const Color hintTextColor = Colors.grey;

// Text Styles
const TextStyle headingStyle = TextStyle(
  color: primaryColor,
  fontSize: 30,
  fontWeight: FontWeight.bold,
);

const TextStyle subheadingStyle = TextStyle(
  color: textColor,
  fontSize: 14,
);

const TextStyle buttonTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

// Image Assets
const String mandaueFoamLogo = 'assets/mandauefoam_Logo.png';
const String googleLogo = 'assets/google_logo.png';

// 🔐 Admin UID (the only account that can open the admin screen)
const String kAdminUid = '0aiv98in2cYnWM08yMaJEDpekyw2';

// lib/constants/app_assets.dart
class AppAssets {
  static const String googleLogo = 'assets/google_logo.png';
  static const String mandauefoamLogo = 'assets/mandauefoam_Logo.png';

// Add more assets here as needed
}
