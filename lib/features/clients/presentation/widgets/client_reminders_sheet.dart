import 'package:flutter/material.dart';

import '../../../../models/transaction.dart';
import '../../../../services/notification_service.dart';
import '../../../../l10n/app_localizations.dart';

class ClientRemindersSheet extends StatelessWidget {
  final List<DebtTransaction> transactions;
  final Function(DebtTransaction) onReschedule;

  const ClientRemindersSheet({
    super.key,
    required this.transactions,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.selectDebtForReminder,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        await NotificationService.instance.showInstantNotification(
                          title: l10n.testNotification,
                          body: l10n.testNotificationBody,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.testNotificationSent),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${l10n.testNotificationFailed}$e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.send, size: 16),
                    label: Text(l10n.test),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Transactions List
            Expanded(
              child: transactions.isEmpty
                  ? const Center(child: Text('لا توجد ديون'))
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: transactions.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isForMe = tx.isForMe;
                        final color =
                            isForMe ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                        final hasActiveReminder = tx.reminderDate != null &&
                            tx.reminderDate!.isAfter(DateTime.now());

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isForMe ? Icons.arrow_upward : Icons.arrow_downward,
                              color: color,
                            ),
                          ),
                          title: Text(
                            '${tx.amount.toStringAsFixed(2)} ${tx.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.details.isNotEmpty
                                    ? tx.details
                                    : (isForMe ? 'له' : 'عليه'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasActiveReminder)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.alarm,
                                        size: 12,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(tx.reminderDate!),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              hasActiveReminder
                                  ? Icons.notifications_active
                                  : Icons.notification_add_outlined,
                              color: hasActiveReminder
                                  ? Colors.orange.shade700
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              onReschedule(tx);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            onReschedule(tx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
