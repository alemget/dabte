import 'package:flutter/material.dart';

class ClientAppBarActions extends StatelessWidget {
  final bool hasPendingReminder;
  final bool showConvertedValues;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onCurrencyTogglePressed;
  final VoidCallback onFiltersPressed;

  const ClientAppBarActions({
    super.key,
    required this.hasPendingReminder,
    required this.showConvertedValues,
    required this.onNotificationsPressed,
    required this.onCurrencyTogglePressed,
    required this.onFiltersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined, 
            size: 20, 
            color: hasPendingReminder ? Colors.orange : Colors.grey.shade700
          ),
          tooltip: 'تذكيرات الديون',
          onPressed: onNotificationsPressed,
        ),
        IconButton(
          icon: Icon(
            showConvertedValues ? Icons.currency_exchange : Icons.currency_exchange_outlined,
            size: 20,
            color: showConvertedValues ? const Color(0xFF5C6EF8) : null,
          ),
          tooltip: showConvertedValues ? 'إخفاء التحويلات' : 'عرض التحويلات',
          onPressed: onCurrencyTogglePressed,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, size: 20),
          onPressed: onFiltersPressed,
        ),
      ],
    );
  }
}
