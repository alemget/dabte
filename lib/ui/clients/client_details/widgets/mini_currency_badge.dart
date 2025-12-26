import 'package:flutter/material.dart';
import '../../../../data/currency_data.dart';
import '../../../widgets/currency_display_helper.dart';

/// شارة عملة صغيرة
class MiniCurrencyBadge extends StatelessWidget {
  final String currency;

  const MiniCurrencyBadge({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final normalized = currency.trim();

    // Try to find currency data
    CurrencyOption? currencyData;
    try {
      currencyData = CurrencyData.all.firstWhere(
        (c) =>
            c.code.toUpperCase() == normalized.toUpperCase() ||
            c.name == normalized,
      );
    } catch (_) {
      // Not found
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
          CurrencyDisplayHelper.getIcon(
            currencyData?.code ?? normalized,
            fallbackEmoji: currencyData?.flag ?? '💰',
            size: 10,
            showGoldText: false, // Too small
          ),
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
