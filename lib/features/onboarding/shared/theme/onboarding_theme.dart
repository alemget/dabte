import 'package:flutter/material.dart';

class OnboardingTheme {
  OnboardingTheme._();

  static const Color primary = Color(0xFF4ECDC4);
  static const Color background = Color(0xFF1a1a2e);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFBFC6D1);
  static const Color border = Color(0x22FFFFFF);

  static const double padding = 24.0;
  static const double cardPadding = 32.0;

  static const TextStyle appTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primary,
    fontFamily: 'Cairo',
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Cairo',
  );

  static TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: textSecondary.withOpacity(0.9),
    fontFamily: 'Cairo',
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      );

  static BoxDecoration get activeCardDecoration => BoxDecoration(
        color: primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primary.withOpacity(0.35)),
      );
}
