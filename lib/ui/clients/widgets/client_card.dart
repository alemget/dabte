import 'package:flutter/material.dart';
import '../../../data/currency_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/client.dart';
import '../../../providers/client_provider.dart';
import '../../widgets/money_amount.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final ClientSummary? summary;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onCallPressed;

  const ClientCard({
    super.key,
    required this.client,
    required this.summary,
    required this.onTap,
    required this.onLongPress,
    this.onCallPressed,
  });

  String _getInitial(String name) =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
    ];
    final hash = name.codeUnits.fold(0, (sum, code) => sum + code);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasDebts = summary != null && summary!.netByCurrency.isNotEmpty;
    final avatarColor = _getAvatarColor(client.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(client.name),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1D1E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (!hasDebts)
                        Text(
                          AppLocalizations.of(context)!.noTransactions,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        )
                      else
                        _DebtIndicators(netByCurrency: summary!.netByCurrency),
                    ],
                  ),
                ),

                // Actions
                if (onCallPressed != null)
                  _IconButton(
                    icon: Icons.phone_outlined,
                    color: const Color(0xFF10B981),
                    onTap: onCallPressed!,
                    size: 32,
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebtIndicators extends StatelessWidget {
  final Map<String, double> netByCurrency;

  const _DebtIndicators({required this.netByCurrency});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: netByCurrency.entries.take(2).map((entry) {
        final isOwed = entry.value > 0;
        final color = isOwed
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444);
        final label = isOwed
            ? AppLocalizations.of(context)!.forMe
            : AppLocalizations.of(context)!.owes;
        final code = CurrencyData.normalizeCode(entry.key);

        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                MoneyAmount(
                  amount: entry.value.abs(),
                  currencyCode: code,
                  fractionDigits: 0,
                  color: color,
                  showCode: true,
                  showIcon: true,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: size * 0.45, color: color),
      ),
    );
  }
}
