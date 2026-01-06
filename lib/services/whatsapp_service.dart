/// WhatsApp Service for DioMax App
/// خدمة إرسال رسائل WhatsApp للتذكير بالديون
library;

import 'package:url_launcher/url_launcher.dart';

/// Service for sending WhatsApp messages to debtors
class WhatsAppService {
  WhatsAppService._();
  static final WhatsAppService instance = WhatsAppService._();

  /// Format phone number for WhatsApp API
  /// Removes spaces, dashes, and ensures proper format
  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If starts with 0, assume local number and remove leading 0
    if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }

    // If doesn't start with +, assume it needs country code
    // This can be customized based on user's preferences
    if (!cleaned.startsWith('+')) {
      // Default to Saudi Arabia (+966) - can be made configurable
      if (!cleaned.startsWith('966')) {
        cleaned = '966$cleaned';
      }
    }

    return cleaned.replaceAll('+', '');
  }

  /// Format debt reminder message
  String formatDebtMessage({
    required String clientName,
    required double amount,
    required String currency,
    required String details,
    required String senderName,
    required bool isForMe,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('السلام عليكم ورحمة الله وبركاته 🙏');
    buffer.writeln();
    buffer.writeln('*مطالبة بسداد دين*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    buffer.writeln();
    buffer.writeln('عزيزي/ *$clientName*،');
    buffer.writeln();
    buffer.writeln('نود تذكيركم بسداد الدين اللي عليكم:');
    buffer.writeln();
    buffer.writeln('💰 *المبلغ:* ${amount.toStringAsFixed(2)} $currency');

    if (details.isNotEmpty) {
      buffer.writeln('📝 *التفاصيل:* $details');
    }

    buffer.writeln();
    buffer.writeln('نأمل سداد هذا المبلغ في أقرب وقت ممكن.');
    buffer.writeln();
    buffer.writeln('شكراً لتعاونكم 🤝');
    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    buffer.writeln('*$senderName*');
    buffer.writeln('_عبر تطبيق ديوماكس_');

    return buffer.toString();
  }

  /// Open WhatsApp with pre-filled message
  /// Returns true if successful, false otherwise
  Future<bool> openWhatsApp({
    required String phone,
    required String message,
  }) async {
    final formattedPhone = _formatPhoneNumber(phone);
    final encodedMessage = Uri.encodeComponent(message);

    // Try wa.me URL (works on most devices)
    final whatsappUrl = Uri.parse(
      'https://wa.me/$formattedPhone?text=$encodedMessage',
    );

    try {
      // Launch directly without canLaunchUrl check
      // canLaunchUrl fails on Android 11+ due to package visibility
      final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (launched) return true;

      // Fallback: try whatsapp:// scheme
      final fallbackUrl = Uri.parse(
        'whatsapp://send?phone=$formattedPhone&text=$encodedMessage',
      );

      return await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      // If all fails, try one more time with different approach
      try {
        final directUrl = Uri.parse('https://wa.me/$formattedPhone');
        return await launchUrl(directUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }
  }

  /// Send debt reminder via WhatsApp
  /// Returns a result indicating success or failure reason
  Future<WhatsAppResult> sendDebtReminder({
    required String? phone,
    required String clientName,
    required double amount,
    required String currency,
    required String details,
    required String senderName,
    required bool isForMe,
  }) async {
    // Check if phone number exists
    if (phone == null || phone.trim().isEmpty) {
      return WhatsAppResult.noPhoneNumber();
    }

    // Format the message
    final message = formatDebtMessage(
      clientName: clientName,
      amount: amount,
      currency: currency,
      details: details,
      senderName: senderName,
      isForMe: isForMe,
    );

    // Try to open WhatsApp
    final success = await openWhatsApp(phone: phone, message: message);

    if (success) {
      return WhatsAppResult.success();
    } else {
      return WhatsAppResult.failed();
    }
  }
}

/// Result of WhatsApp operation
class WhatsAppResult {
  final bool success;
  final WhatsAppError? error;

  WhatsAppResult._({required this.success, this.error});

  factory WhatsAppResult.success() => WhatsAppResult._(success: true);

  factory WhatsAppResult.noPhoneNumber() =>
      WhatsAppResult._(success: false, error: WhatsAppError.noPhoneNumber);

  factory WhatsAppResult.failed() =>
      WhatsAppResult._(success: false, error: WhatsAppError.launchFailed);
}

/// WhatsApp error types
enum WhatsAppError { noPhoneNumber, launchFailed }
