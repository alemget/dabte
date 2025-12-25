import 'package:flutter/material.dart';
import '../models/models.dart';
import 'section_card.dart';

/// بطاقة نظرة عامة على العملاء - تصميم أنيق وسهل القراءة
/// Elegant and readable clients overview card
class ClientsOverviewCard extends StatelessWidget {
  final int totalClients;
  final int clientsWithDebts;
  final List<ClientDebtInfo> topDebtors;

  const ClientsOverviewCard({
    super.key,
    required this.totalClients,
    required this.clientsWithDebts,
    required this.topDebtors,
  });

  @override
  Widget build(BuildContext context) {
    final clientsWithoutDebts = totalClients - clientsWithDebts;

    return SectionCard(
      title: 'العملاء',
      icon: Icons.people_outline,
      iconColor: const Color(0xFF3B82F6),
      child: Column(
        children: [
          // ═══════════════════════════════════════════════════════════
          // إحصائيات العملاء - 3 دوائر ملونة
          // ═══════════════════════════════════════════════════════════
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CircleStat(
                value: totalClients,
                label: 'إجمالي',
                color: const Color(0xFF3B82F6),
                icon: Icons.people,
              ),
              _CircleStat(
                value: clientsWithDebts,
                label: 'لديهم ديون',
                color: const Color(0xFFF59E0B),
                icon: Icons.account_balance_wallet,
              ),
              _CircleStat(
                value: clientsWithoutDebts,
                label: 'بدون ديون',
                color: const Color(0xFF10B981),
                icon: Icons.check_circle,
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════
          // قائمة أكثر العملاء ديوناً
          // ═══════════════════════════════════════════════════════════
          if (topDebtors.isNotEmpty) ...[
            const SizedBox(height: 16),

            // العنوان مع خط فاصل
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 12,
                        color: const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'أعلى الديون',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(height: 1, color: Colors.grey.shade200),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // القائمة
            ...topDebtors.asMap().entries.map((entry) {
              return _DebtorRow(
                rank: entry.key + 1,
                name: entry.value.name,
                amount: entry.value.primaryDebt,
                currency: entry.value.primaryCurrency,
                isPositive: entry.value.owesMe,
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// دائرة إحصائية مع أيقونة
/// ═══════════════════════════════════════════════════════════════════════════
class _CircleStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final IconData icon;

  const _CircleStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الدائرة
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // التسمية
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// صف العميل المدين
/// ═══════════════════════════════════════════════════════════════════════════
class _DebtorRow extends StatelessWidget {
  final int rank;
  final String name;
  final double amount;
  final String currency;
  final bool isPositive;

  const _DebtorRow({
    required this.rank,
    required this.name,
    required this.amount,
    required this.currency,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // 🏆 ميدالية الترتيب
          _RankBadge(rank: rank),
          const SizedBox(width: 10),

          // 👤 اسم العميل
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1D1E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 💰 المبلغ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: color,
                ),
                const SizedBox(width: 3),
                Text(
                  '${_formatAmount(amount)} $currency',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
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
    final absAmount = amount.abs();
    if (absAmount == absAmount.roundToDouble()) {
      return absAmount.toInt().toString();
    }
    return absAmount.toStringAsFixed(2);
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// شارة الترتيب (ذهبي/فضي/برونزي)
/// ═══════════════════════════════════════════════════════════════════════════
class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTop3 ? _getColor().withOpacity(0.15) : Colors.grey.shade100,
        border: isTop3
            ? Border.all(color: _getColor().withOpacity(0.5), width: 1.5)
            : null,
      ),
      child: Center(
        child: isTop3
            ? Icon(_getIcon(), size: 12, color: _getColor())
            : Text(
                '$rank',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
      ),
    );
  }

  Color _getColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // ذهبي
      case 2:
        return const Color(0xFFC0C0C0); // فضي
      case 3:
        return const Color(0xFFCD7F32); // برونزي
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon() {
    switch (rank) {
      case 1:
        return Icons.emoji_events; // كأس
      case 2:
        return Icons.military_tech; // ميدالية
      case 3:
        return Icons.workspace_premium; // نجمة
      default:
        return Icons.circle;
    }
  }
}
