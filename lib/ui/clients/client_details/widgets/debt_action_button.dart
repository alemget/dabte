/// Debt Action Button Widget
/// زر إجراءات الدين (تذكير واتساب / فاتورة)
library;

import 'package:flutter/material.dart';

import '../../../../data/currency_data.dart';
import '../../../../data/debt_database.dart';
import '../../../../models/client.dart';
import '../../../../models/transaction.dart';
import '../../../../services/whatsapp_service.dart';
// TODO: سيتم استخدامه عند تفعيل ميزة PDF
// import '../../../../services/invoice_service.dart';
import '../../../../services/contact_picker_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/money_amount.dart';

/// A button that shows debt action options (WhatsApp reminder / Invoice)
class DebtActionButton extends StatefulWidget {
  final DebtTransaction transaction;
  final Client client;
  final VoidCallback? onClientUpdated;

  const DebtActionButton({
    super.key,
    required this.transaction,
    required this.client,
    this.onClientUpdated,
  });

  @override
  State<DebtActionButton> createState() => _DebtActionButtonState();
}

class _DebtActionButtonState extends State<DebtActionButton> {
  late Client _currentClient;

  @override
  void initState() {
    super.initState();
    _currentClient = widget.client;
  }

  @override
  void didUpdateWidget(DebtActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.client != widget.client) {
      _currentClient = widget.client;
    }
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _DebtActionSheetContent(
        transaction: widget.transaction,
        client: _currentClient,
        onWhatsAppTap: () {
          Navigator.of(sheetContext).pop();
          _handleWhatsAppAction();
        },
        onInvoiceTap: () {
          Navigator.of(sheetContext).pop();
          _handleInvoiceAction();
        },
      ),
    );
  }

  Future<void> _handleWhatsAppAction() async {
    // Check if phone number exists
    if (_currentClient.phone == null || _currentClient.phone!.trim().isEmpty) {
      // Show dialog to add phone number
      final newPhone = await _showAddPhoneDialog();
      if (newPhone == null || newPhone.isEmpty) return;

      // Update local client reference
      _currentClient = _currentClient.copyWith(phone: newPhone);
    }

    // Now send WhatsApp
    final profileInfo = await DebtDatabase.instance.getProfileInfo();
    final senderName = profileInfo?['name'] as String? ?? 'ديوني ماكس';

    final result = await WhatsAppService.instance.sendDebtReminder(
      phone: _currentClient.phone,
      clientName: _currentClient.name,
      amount: widget.transaction.amount,
      currency: widget.transaction.currency,
      details: widget.transaction.details,
      senderName: senderName,
      isForMe: widget.transaction.isForMe,
    );

    if (!result.success && mounted) {
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

  Future<void> _handleInvoiceAction() async {
    // TODO: سيتم تفعيل ميزة فاتورة PDF لاحقاً
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'قريباً! 🚀',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'ميزة فاتورة PDF ستتوفر قريباً',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<String?> _showAddPhoneDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
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
                'أضف رقم جوال ${_currentClient.name} للمتابعة',
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.contacts_outlined,
                      color: Colors.blue.shade600,
                    ),
                    tooltip: 'اختيار من جهات الاتصال',
                    onPressed: () async {
                      final phone = await ContactPickerService.instance
                          .pickPhoneNumber();
                      if (phone != null) {
                        phoneController.text = phone;
                      }
                    },
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

    // If user entered a phone number, save it to database
    if (result != null && result.isNotEmpty) {
      // Save to database
      await DebtDatabase.instance.updateClient(
        _currentClient.id!,
        _currentClient.name,
        phone: result,
      );

      // Notify parent to refresh
      widget.onClientUpdated?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('تم حفظ رقم الجوال بنجاح ✓'),
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

      return result;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showActionSheet,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.send_outlined,
            size: 18,
            color: Colors.blue.shade600,
          ),
        ),
      ),
    );
  }
}

/// Internal sheet content widget
class _DebtActionSheetContent extends StatelessWidget {
  final DebtTransaction transaction;
  final Client client;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onInvoiceTap;

  const _DebtActionSheetContent({
    required this.transaction,
    required this.client,
    required this.onWhatsAppTap,
    required this.onInvoiceTap,
  });

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
                          currencyCode: CurrencyData.normalizeCode(transaction.currency),
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
            ListTile(
              onTap: onWhatsAppTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_outlined,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              title: Text(
                l10n.sendTextReminder,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.sendViaWhatsApp,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),

            // Invoice option
            ListTile(
              onTap: onInvoiceTap,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              title: Text(
                l10n.generateInvoice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                l10n.shareInvoice,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
