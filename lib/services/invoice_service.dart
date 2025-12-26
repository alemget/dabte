/// Invoice Service for Debt Max App
/// خدمة إنشاء ومشاركة فواتير المطالبة
library;

import 'dart:math';

import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../data/debt_database.dart';
import '../models/client.dart';
import '../models/transaction.dart';

/// Service for generating and sharing invoices
class InvoiceService {
  InvoiceService._();
  static final InvoiceService instance = InvoiceService._();

  /// Generate unique invoice number
  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final random = Random().nextInt(999).toString().padLeft(3, '0');
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$random';
  }

  /// Format date in Arabic style
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(date);
  }

  /// Generate invoice text content
  Future<String> generateInvoice({
    required DebtTransaction transaction,
    required Client client,
  }) async {
    // Get profile info for sender details
    final profileInfo = await DebtDatabase.instance.getProfileInfo();

    final senderName = profileInfo?['name'] as String? ?? 'ديوني ماكس';
    final senderPhone = profileInfo?['phone'] as String? ?? '';
    final senderAddress = profileInfo?['address'] as String? ?? '';
    final footer = profileInfo?['footer'] as String? ?? '';

    final invoiceNumber = _generateInvoiceNumber();
    final issueDate = _formatDate(DateTime.now());
    final transactionDate = _formatDate(transaction.date);

    final buffer = StringBuffer();

    // Header
    buffer.writeln('╔════════════════════════════════════════╗');
    buffer.writeln('║           📄 فاتورة مطالبة             ║');
    buffer.writeln('║          PAYMENT INVOICE               ║');
    buffer.writeln('╚════════════════════════════════════════╝');
    buffer.writeln();

    // Invoice Details
    buffer.writeln('┌─────────────────────────────────────────┐');
    buffer.writeln('│ 🔢 رقم الفاتورة: $invoiceNumber');
    buffer.writeln('│ 📅 تاريخ الإصدار: $issueDate');
    buffer.writeln('└─────────────────────────────────────────┘');
    buffer.writeln();

    // Sender Info
    buffer.writeln('━━━━━━━━━━ من (المُطالِب) ━━━━━━━━━━');
    buffer.writeln('👤 الاسم: $senderName');
    if (senderPhone.isNotEmpty) {
      buffer.writeln('📱 الهاتف: $senderPhone');
    }
    if (senderAddress.isNotEmpty) {
      buffer.writeln('📍 العنوان: $senderAddress');
    }
    buffer.writeln();

    // Client Info
    buffer.writeln('━━━━━━━━━━ إلى (المَدين) ━━━━━━━━━━');
    buffer.writeln('👤 الاسم: ${client.name}');
    if (client.phone != null && client.phone!.isNotEmpty) {
      buffer.writeln('📱 الهاتف: ${client.phone}');
    }
    buffer.writeln();

    // Transaction Details
    buffer.writeln('━━━━━━━━━━ تفاصيل الدين ━━━━━━━━━━');
    buffer.writeln(
      '💰 المبلغ المستحق: ${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
    );
    buffer.writeln('📅 تاريخ المعاملة: $transactionDate');
    if (transaction.details.isNotEmpty) {
      buffer.writeln('📝 الوصف: ${transaction.details}');
    }
    buffer.writeln(
      '📊 النوع: ${transaction.isForMe ? "دين له (مستحق لي)" : "دين عليه (مستحق له)"}',
    );
    buffer.writeln();

    // Total
    buffer.writeln('╔════════════════════════════════════════╗');
    buffer.writeln('║  💵 المبلغ الإجمالي المطلوب:');
    buffer.writeln(
      '║     ${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
    );
    buffer.writeln('╚════════════════════════════════════════╝');
    buffer.writeln();

    // Payment Request
    buffer.writeln('┌─────────────────────────────────────────┐');
    buffer.writeln('│ 🙏 يرجى سداد هذا المبلغ في أقرب وقت    │');
    buffer.writeln('│    ممكن. شكراً لتعاونكم.                │');
    buffer.writeln('└─────────────────────────────────────────┘');
    buffer.writeln();

    // Footer
    if (footer.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln(footer);
      buffer.writeln();
    }

    // App Signature
    buffer.writeln('─────────────────────────────────────────');
    buffer.writeln('📱 تم إنشاء هذه الفاتورة بواسطة');
    buffer.writeln('   تطبيق ديوني ماكس - Debt Max');
    buffer.writeln('─────────────────────────────────────────');

    return buffer.toString();
  }

  /// Share invoice via system share dialog
  Future<InvoiceResult> shareInvoice({
    required DebtTransaction transaction,
    required Client client,
  }) async {
    try {
      final invoiceText = await generateInvoice(
        transaction: transaction,
        client: client,
      );

      // Use ShareResult to check if share was successful
      final result = await Share.share(
        invoiceText,
        subject: 'فاتورة مطالبة - ${client.name}',
      );

      // ShareResultStatus can be: success, dismissed, or unavailable
      if (result.status == ShareResultStatus.unavailable) {
        return InvoiceResult.failed('المشاركة غير متاحة على هذا الجهاز');
      }

      return InvoiceResult.success();
    } catch (e) {
      return InvoiceResult.failed(e.toString());
    }
  }
}

/// Result of invoice operation
class InvoiceResult {
  final bool success;
  final String? error;

  InvoiceResult._({required this.success, this.error});

  factory InvoiceResult.success() => InvoiceResult._(success: true);

  factory InvoiceResult.failed(String message) =>
      InvoiceResult._(success: false, error: message);
}
