/// Debt Action Sheet Widget
/// قائمة إجراءات الدين المنبثقة
library;

import 'package:flutter/material.dart';

import '../../../../data/currency_data.dart';
import '../../../../data/debt_database.dart';
import '../../../../models/client.dart';
import '../../../../models/transaction.dart';
import '../../../../services/whatsapp_service.dart';
import '../../../../services/invoice_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/money_amount.dart';

/// Bottom sheet with debt action options
class DebtActionSheet extends StatelessWidget {
  final DebtTransaction transaction;
  final Client client;
  final VoidCallback? onPhoneUpdated;

  const DebtActionSheet({
    super.key,
    required this.transaction,
    required this.client,
    this.onPhoneUpdated,
  });

  Future<void> _sendWhatsAppReminder(BuildContext context) async {
    // Check if phone number exists first
    if (client.phone == null || client.phone!.trim().isEmpty) {
      Navigator.of(context).pop();

      // Show dialog to add phone number
      if (context.mounted) {
        await _showAddPhoneDialog(context);
      }
      return;
    }

    Navigator.of(context).pop();

    // Get sender name from profile
    final profileInfo = await DebtDatabase.instance.getProfileInfo();
    final senderName = profileInfo?['name'] as String? ?? ' ماكس';

    final result = await WhatsAppService.instance.sendDebtReminder(
      phone: client.phone,
      clientName: client.name,
      amount: transaction.amount,
      currency: transaction.currency,
      details: transaction.details,
      senderName: senderName,
      isForMe: transaction.isForMe,
    );

    if (!result.success && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.whatsappNotInstalled)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _showAddPhoneDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final phoneController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.phone_android,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.pleaseAddPhoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أضف رقم جوال ${client.name} للمتابعة',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '05XXXXXXXX',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: Colors.grey.shade500,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final phone = phoneController.text.trim();
                if (phone.isNotEmpty) {
                  Navigator.of(dialogContext).pop(phone);
                }
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // If user entered a phone number, save it and send WhatsApp
    if (result != null && result.isNotEmpty && context.mounted) {
      // Save phone number to database
      await DebtDatabase.instance.updateClient(
        client.id!,
        client.name,
        phone: result,
      );

      // Notify parent to refresh client data
      onPhoneUpdated?.call();

      // Show success message
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('تم حفظ رقم الجوال بنجاح'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      // Get sender name from profile
      final profileInfo = await DebtDatabase.instance.getProfileInfo();
      final senderName = profileInfo?['name'] as String? ?? 'ديوماكس';

      // Now send WhatsApp with the new phone
      await WhatsAppService.instance.sendDebtReminder(
        phone: result,
        clientName: client.name,
        amount: transaction.amount,
        currency: transaction.currency,
        details: transaction.details,
        senderName: senderName,
        isForMe: transaction.isForMe,
      );
    }
  }

  Future<void> _generateInvoice(BuildContext context) async {
    Navigator.of(context).pop();

    final result = await InvoiceService.instance.shareInvoice(
      transaction: transaction,
      client: client,
    );

    if (!result.success && context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.errorOccurred)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.send_outlined,
                      color: Colors.blue.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.sendReminder,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MoneyAmount(
                          amount: transaction.amount,
                          currencyCode: CurrencyData.normalizeCode(
                            transaction.currency,
                          ),
                          fractionDigits: 2,
                          showIcon: true,
                          showCode: true,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // WhatsApp option
            _ActionTile(
              icon: Icons.chat_outlined,
              iconColor: Colors.green,
              title: l10n.sendTextReminder,
              subtitle: l10n.sendViaWhatsApp,
              onTap: () => _sendWhatsAppReminder(context),
            ),

            // Invoice option
            _ActionTile(
              icon: Icons.receipt_long_outlined,
              iconColor: Colors.orange,
              title: l10n.generateInvoice,
              subtitle: l10n.shareInvoice,
              onTap: () => _generateInvoice(context),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Individual action tile in the sheet
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
    );
  }
}
