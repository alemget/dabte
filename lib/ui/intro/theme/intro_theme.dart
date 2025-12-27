import 'package:flutter/material.dart';

/// Theme constants for the intro/onboarding screens
class IntroTheme {
  IntroTheme._();

  // ─────────────────────────────────────────────────────────────────
  // Colors
  // ─────────────────────────────────────────────────────────────────

  /// Primary accent color (teal)
  static const Color primary = Color(0xFF4ECDC4);

  /// Background color (white)
  static const Color background = Colors.white;

  /// Text color (dark)
  static const Color textPrimary = Color(0xFF1a1a2e);

  /// Text color (secondary)
  static const Color textSecondary = Color(0xFF6B7280);

  /// Text color (hint)
  static const Color textHint = Color(0xFF9CA3AF);

  /// Border color (light)
  static const Color border = Color(0xFFE5E7EB);

  /// Card background
  static const Color cardBackground = Color(0xFFF9FAFB);

  // ─────────────────────────────────────────────────────────────────
  // Text Styles
  // ─────────────────────────────────────────────────────────────────

  /// App title style
  static const TextStyle appTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primary,
    fontFamily: 'Cairo',
  );

  /// Page title style
  static const TextStyle pageTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Cairo',
  );

  /// Subtitle style
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: textSecondary,
    fontFamily: 'Cairo',
  );

  /// Body text style
  static const TextStyle body = TextStyle(fontSize: 14, color: textSecondary);

  // ─────────────────────────────────────────────────────────────────
  // Decorations
  // ─────────────────────────────────────────────────────────────────

  /// Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: border),
  );

  /// Active card decoration
  static BoxDecoration get activeCardDecoration => BoxDecoration(
    color: primary.withOpacity(0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: primary.withOpacity(0.3)),
  );

  // ─────────────────────────────────────────────────────────────────
  // Dimensions
  // ─────────────────────────────────────────────────────────────────

  /// Standard padding
  static const double padding = 24.0;

  /// Card padding
  static const double cardPadding = 32.0;

  /// Border radius
  static const double borderRadius = 20.0;
}
