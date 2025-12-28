import 'package:flutter/material.dart';
import '../../../widgets/currency_display_helper.dart';

/// عنصر ملخص مدمج (له، عليه، الصافي)
class CompactSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const CompactSummaryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyDisplayHelper.format(value, fractionDigits: 0),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
