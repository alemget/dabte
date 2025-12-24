import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class ClientFilterSheet extends StatefulWidget {
  final String currentCurrencyFilter;
  final String currentTypeFilter;
  final String currentDateOrder;
  final List<String> availableCurrencies;
  final Function(String currency, String type, String dateOrder) onApply;
  final VoidCallback onReset;

  const ClientFilterSheet({
    super.key,
    required this.currentCurrencyFilter,
    required this.currentTypeFilter,
    required this.currentDateOrder,
    required this.availableCurrencies,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ClientFilterSheet> createState() => _ClientFilterSheetState();
}

class _ClientFilterSheetState extends State<ClientFilterSheet> {
  late String _tempCurrencyFilter;
  late String _tempTypeFilter;
  late String _tempDateOrder;

  @override
  void initState() {
    super.initState();
    _tempCurrencyFilter = widget.currentCurrencyFilter;
    _tempTypeFilter = widget.currentTypeFilter;
    _tempDateOrder = widget.currentDateOrder;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.filter,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(l10n.clearAllData),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildFilterSection(
              l10n.currency,
              Icons.attach_money,
              widget.availableCurrencies,
              _tempCurrencyFilter,
              (val) => setState(() => _tempCurrencyFilter = val),
            ),
            const SizedBox(height: 24),
            _buildFilterSection(
              l10n.type,
              Icons.compare_arrows,
              [l10n.all, l10n.forMe, l10n.onMe],
              _tempTypeFilter,
              (val) => setState(() => _tempTypeFilter = val),
            ),
            const SizedBox(height: 24),
            _buildFilterSection(
              'ترتيب التاريخ',
              Icons.calendar_today,
              ['الأحدث', l10n.oldest],
              _tempDateOrder,
              (val) => setState(() => _tempDateOrder = val),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _tempCurrencyFilter,
                    _tempTypeFilter,
                    _tempDateOrder,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C6EF8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5C6EF8)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5C6EF8)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
