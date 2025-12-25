import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/models.dart';

/// بطاقة ملخص الحساب الرئيسي - نسخة مدمجة
/// Compact summary dashboard card
class SummaryCard extends StatelessWidget {
  final ReportSummary summary;

  const SummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final primaryCurrency = summary.netBalance.isNotEmpty
        ? summary.netBalance.keys.first
        : '';
    final forMe = summary.totalForMe[primaryCurrency] ?? 0;
    final onMe = summary.totalOnMe[primaryCurrency] ?? 0;
    final net = summary.netBalance[primaryCurrency] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // العنوان - أصغر
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ملخص الحساب',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // الإحصائيات الرئيسية
          Row(
            children: [
              Expanded(
                child: _SummaryStatItem(
                  title: l10n.forMe,
                  value: _formatAmount(forMe),
                  currency: primaryCurrency,
                  icon: Icons.arrow_downward,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _SummaryStatItem(
                  title: l10n.onMe,
                  value: _formatAmount(onMe),
                  currency: primaryCurrency,
                  icon: Icons.arrow_upward,
                  iconColor: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // صافي الحساب - أصغر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.net}: ',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Icon(
                  net >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: net >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${net >= 0 ? '+' : ''}${_formatAmount(net)} $primaryCurrency',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toStringAsFixed(2);
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String title;
  final String value;
  final String currency;
  final IconData icon;
  final Color iconColor;

  const _SummaryStatItem({
    required this.title,
    required this.value,
    required this.currency,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 10, color: iconColor),
            const SizedBox(width: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$value $currency',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
