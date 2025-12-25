import 'package:flutter/material.dart';
import '../models/models.dart';
import 'section_card.dart';
import 'custom_progress_bar.dart';

/// بطاقة توزيع العملات - نسخة مدمجة
/// Compact currency breakdown card
class CurrencyReportCard extends StatelessWidget {
  final List<CurrencyBreakdown> currencies;

  const CurrencyReportCard({super.key, required this.currencies});

  @override
  Widget build(BuildContext context) {
    if (currencies.isEmpty) {
      return SectionCard(
        title: 'توزيع العملات',
        icon: Icons.currency_exchange,
        iconColor: const Color(0xFFF59E0B),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(
                  Icons.currency_exchange,
                  size: 28,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Text(
                  'لا توجد معاملات بعد',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final maxValue = currencies.fold<double>(
      0,
      (max, c) => c.absoluteNet > max ? c.absoluteNet : max,
    );

    return SectionCard(
      title: 'توزيع العملات',
      icon: Icons.currency_exchange,
      iconColor: const Color(0xFFF59E0B),
      child: Column(
        children: currencies
            .map(
              (currency) =>
                  _CurrencyItem(currency: currency, maxValue: maxValue),
            )
            .toList(),
      ),
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final CurrencyBreakdown currency;
  final double maxValue;

  const _CurrencyItem({required this.currency, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final color = currency.isPositive
        ? const Color(0xFF10B981)
        : currency.isNegative
        ? const Color(0xFFEF4444)
        : const Color(0xFF64748B);
    final progress = maxValue > 0 ? currency.absoluteNet / maxValue : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    _getCurrencySymbol(currency.currency),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.currency,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _getStatusText(currency),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${currency.net >= 0 ? '+' : ''}${_formatAmount(currency.net)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'صافي',
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomProgressBar(progress: progress, color: color, height: 4),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DetailItem(
                label: 'لي',
                value: _formatAmount(currency.forMe),
                color: const Color(0xFF10B981),
              ),
              _DetailItem(
                label: 'عليّ',
                value: _formatAmount(currency.onMe),
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'SAR':
      case 'ريال':
      case 'ر.س':
        return '﷼';
      case 'USD':
      case 'دولار':
        return '\$';
      case 'EUR':
      case 'يورو':
        return '€';
      case 'GBP':
        return '£';
      case 'AED':
        return 'د.إ';
      default:
        return currency.isNotEmpty ? currency[0].toUpperCase() : '?';
    }
  }

  String _getStatusText(CurrencyBreakdown currency) {
    if (currency.isPositive) return 'لي أكثر';
    if (currency.isNegative) return 'عليّ أكثر';
    return 'متعادل';
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble())
      return amount.toInt().abs().toString();
    return amount.abs().toStringAsFixed(2);
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
