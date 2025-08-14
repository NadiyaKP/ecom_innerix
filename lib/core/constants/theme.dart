import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFD4A574);
  static const Color backgroundColor = Colors.white;
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Colors.grey;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color facebookColor = Color(0xFF1877F2);
  
  // Grey shades
  static final Color fillColor = Colors.grey[50]!;
  static final Color borderColor = Colors.grey[200]!;
  static final Color disabledColor = Colors.grey[300]!;

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    height: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: backgroundColor,
  );

  static const TextStyle linkText = TextStyle(
    color: primaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle socialButtonText = TextStyle(
    fontSize: 16,
    color: textPrimaryColor,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle signUpLinkText = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle hintText = TextStyle(
    color: textSecondaryColor,
  );

  // Input Decoration
  static InputDecoration getInputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintText: hintText,
      hintStyle: AppTheme.hintText,
      suffixIcon: suffixIcon,
    );
  }

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        disabledBackgroundColor: disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );

  static ButtonStyle get outlinedButtonStyle => OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 40.0;

  // Button dimensions
  static const double buttonHeight = 56.0;
  static const double iconSize = 20.0;

  // Border radius
  static const double borderRadius = 12.0;

  // Progress indicator
  static const Widget loadingIndicator = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      color: Colors.white,
      strokeWidth: 2,
    ),
  );

  static const Widget loadingIndicatorDark = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      color: Colors.black54,
      strokeWidth: 2,
    ),
  );
}