import 'package:flutter/material.dart';
import '../../../../data/currency_data.dart';

/// شارة عملة صغيرة
class MiniCurrencyBadge extends StatelessWidget {
  final String currency;

  const MiniCurrencyBadge({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final normalized = currency.trim();
    String emoji;

    try {
      final item = CurrencyData.all.firstWhere(
        (c) =>
            c.code.toUpperCase() == normalized.toUpperCase() ||
            c.name == normalized,
      );
      emoji = item.flag;
    } catch (_) {
      emoji = '💰';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            normalized,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
