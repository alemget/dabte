import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/debt_database.dart';
import '../../../../models/client.dart';
import '../../../../models/transaction.dart';
import '../../../../services/notification_service.dart';

class ReminderHandler {
  /// عرض منتقي التذكير وجدولة الإشعار
  static Future<void> showReminderPicker({
    required BuildContext context,
    required DebtTransaction tx,
    required Client client,
    required VoidCallback onSuccess,
  }) async {
    // اختيار التاريخ
    final pickedDate = await showDatePicker(
      context: context,
      useRootNavigator: true,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF97316)),
        ),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );

    if (pickedDate == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 200));

    // اختيار الوقت
    if (!context.mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      useRootNavigator: true,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFF97316)),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
      ),
    );

    if (pickedTime == null) return;

    // إنشاء DateTime كامل
    final reminderDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // التحقق من أن الوقت في المستقبل
    final now = DateTime.now();
    if (reminderDateTime.isBefore(now)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('الرجاء اختيار وقت في المستقبل'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      // 1. جدولة الإشعار
      await NotificationService.instance.scheduleDebtReminder(
        transaction: tx,
        client: client,
        scheduledTime: reminderDateTime,
      );

      // 2. تحديث المعاملة في قاعدة البيانات (حفظ وقت التذكير)
      final updatedTx = tx.copyWith(reminderDate: reminderDateTime);
      await DebtDatabase.instance.updateTransaction(updatedTx);

      // 3. تحديث الواجهة عبر callback
      onSuccess();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تم جدولة التذكير بنجاح في ${pickedDate.day}/${pickedDate.month} الساعة ${pickedTime.format(context)}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('فشل جدولة التذكير: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
