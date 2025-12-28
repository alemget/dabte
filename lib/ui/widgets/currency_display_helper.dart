import 'package:flutter/material.dart';
import '../../data/currency_data.dart';

/// Helper class to standardize currency icon display across the app
class CurrencyDisplayHelper {
  /// Returns the appropriate widget for a currency code (Icon, gold bar, or text emoji)
  static Widget getIcon(
    String code, {
    double size = 16,
    String? fallbackEmoji,
    bool showGoldText = true,
  }) {
    try {
      final normalized = CurrencyData.normalizeCode(code);

      // Check for standard currencies with Icons
      final currency = CurrencyData.all.firstWhere(
        (c) => c.code.toUpperCase() == normalized,
      );

      // GOLD should look like other currencies (emoji/flag), not a special icon
      if (normalized.startsWith('GOLD')) {
        return Text(currency.flag, style: TextStyle(fontSize: size));
      }

      if (currency.icon != null) {
        return Icon(currency.icon, size: size, color: Colors.amber.shade700);
      }

      // Fallback to Flag/Emoji
      return Text(currency.flag, style: TextStyle(fontSize: size));
    } catch (_) {
      // Final fallback
      return Text(fallbackEmoji ?? '💰', style: TextStyle(fontSize: size));
    }
  }
}
