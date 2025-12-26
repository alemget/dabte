import 'package:flutter/material.dart';
import '../../data/currency_data.dart';
import 'gold_bar_icon.dart';

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

      // Gold karats: use a dedicated gold bar icon (24/22/21/18)
      if (normalized.startsWith('GOLD')) {
        final karat = normalized.replaceAll('GOLD', '');
        final width = size * 2.0;
        final height = size * 1.0;
        return GoldBarIcon(
          karat: karat,
          width: width,
          height: height,
          showText: showGoldText,
        );
      }

      // Check for standard currencies with Icons
      final currency = CurrencyData.all.firstWhere(
        (c) => c.code.toUpperCase() == normalized,
      );

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
