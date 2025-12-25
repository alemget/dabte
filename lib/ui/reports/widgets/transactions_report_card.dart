import 'package:flutter/material.dart';
import '../models/models.dart';
import 'section_card.dart';
import 'custom_progress_bar.dart';

/// بطاقة تقرير المعاملات - نسخة مدمجة
/// Compact transactions report card
class TransactionsReportCard extends StatelessWidget {
  final TransactionStats stats;

  const TransactionsReportCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'تقرير المعاملات',
      icon: Icons.receipt_long_outlined,
      iconColor: const Color(0xFF8B5CF6),
      child: Column(
        children: [
          // إحصائيات سريعة - أصغر
          Row(
            children: [
              Expanded(
                child: _QuickStatItem(
                  value: stats.totalCount.toString(),
                  label: 'معاملة',
                  icon: Icons.receipt_outlined,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickStatItem(
                  value: stats.thisWeekCount.toString(),
                  label: 'هذا الأسبوع',
                  icon: Icons.date_range,
                  color: const Color(0xFF06B6D4),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _QuickStatItem(
                  value: stats.thisMonthCount.toString(),
                  label: 'هذا الشهر',
                  icon: Icons.calendar_month,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // توزيع المعاملات - أصغر
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توزيع المعاملات',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                _ProgressItem(
                  label: 'لي (أستحق)',
                  count: stats.forMeCount,
                  percentage: stats.forMePercentage,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 8),
                _ProgressItem(
                  label: 'عليّ (أدين)',
                  count: stats.onMeCount,
                  percentage: stats.onMePercentage,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _QuickStatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final int count;
  final double percentage;
  final Color color;

  const _ProgressItem({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Row(
              children: [
                Text(
                  '$count',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomProgressBar(progress: percentage / 100, color: color, height: 4),
      ],
    );
  }
}
