import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/debt_database.dart';
import '../../data/currency_data.dart';
import '../../models/client.dart';
import '../../models/transaction.dart';
import '../../services/notification_service.dart';
import 'add_edit_transaction_page.dart';
import 'add_edit_client_page.dart';
import '../../features/clients/presentation/widgets/client_app_bar_actions.dart';
import '../../features/clients/presentation/widgets/client_reminders_sheet.dart';
import '../../features/clients/presentation/widgets/client_filter_sheet.dart';
import '../../l10n/app_localizations.dart';

class ClientDetailsPage extends StatefulWidget {
  final Client client;

  const ClientDetailsPage({super.key, required this.client});

  @override
  State<ClientDetailsPage> createState() => _ClientDetailsPageState();
}

class _ClientDetailsPageState extends State<ClientDetailsPage> {
  bool _loading = true;
  List<DebtTransaction> _transactions = [];
  double _forMe = 0;
  double _onMe = 0;

  String _getLocalizedCurrencyName(String rawName) {
    if (rawName == 'LOCAL' || rawName == 'local')
      return AppLocalizations.of(context)!.local;

    final searchKey = CurrencyData.normalizeCode(rawName);

    try {
      final currency = CurrencyData.all.firstWhere(
        (c) => c.code == searchKey || c.name == searchKey,
      );
      return currency.getLocalizedName(context);
    } catch (_) {
      return rawName;
    }
  }

  String _currencyFilter = 'الكل';
  String _typeFilter = 'الكل';
  String _dateOrder = 'الأحدث';

  List<_CurrencyRate> _currencyRates = [];
  _CurrencyRate? _localCurrency;
  _CurrencyRate? _sarCurrency;

  // New: Multi-currency display
  String _selectedCurrencyCode = 'local'; // العملة المختارة حالياً
  Map<String, _CurrencySummary> _currencySummaries = {}; // ملخص كل عملة
  bool _showConvertedValues = false; // عرض القيم المحولة

  // New: Notification state
  bool _hasPendingReminder = false;
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _loadData();
    _startReminderCheck();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  void _startReminderCheck() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) _updatePendingReminderStatus();
    });
  }

  void _updatePendingReminderStatus() {
    final now = DateTime.now();
    final hasPending = _transactions.any(
      (tx) => tx.reminderDate != null && tx.reminderDate!.isAfter(now),
    );

    if (hasPending != _hasPendingReminder) {
      setState(() => _hasPendingReminder = hasPending);
    }
  }

  Future<void> _loadCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('currencies_json');

    List<_CurrencyRate> list;
    if (raw == null) {
      list = const [
        _CurrencyRate(name: 'YER', code: 'YER', rate: 1.0, isLocal: true),
        _CurrencyRate(name: 'SAR', code: 'SAR', rate: 100.0, isLocal: false),
        _CurrencyRate(name: 'USD', code: 'USD', rate: 300.0, isLocal: false),
      ];
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      list = decoded
          .where(
            (e) => (e['isActive'] as bool? ?? true),
          ) // تصفية العملات المتوقفة
          .map(
            (e) => _CurrencyRate(
              name: e['name'] as String,
              code: e['code'] as String,
              rate: (e['rate'] as num).toDouble(),
              isLocal: e['isLocal'] as bool? ?? false,
            ),
          )
          .toList();

      if (!list.any((c) => c.isLocal)) {
        list = list
            .map(
              (c) => c.code == 'YER'
                  ? c.copyWith(isLocal: true)
                  : c.copyWith(isLocal: false),
            )
            .toList();
      }
    }

    final local = list.firstWhere((c) => c.isLocal, orElse: () => list.first);
    final sar = list.firstWhere(
      (c) => c.code == 'SAR' || c.name == 'سعودي',
      orElse: () => local,
    );

    setState(() {
      _currencyRates = list;
      _localCurrency = local;
      _sarCurrency = sar.code == local.code ? null : sar;
    });

    _calculateCurrencySummaries();
  }

  double _findRateForCurrency(String currency) {
    final trimmed = currency.trim();

    if (_localCurrency != null &&
        (trimmed == _localCurrency!.name || trimmed == _localCurrency!.code)) {
      return 1.0;
    }

    // تطبيع العملة للبحث عنها
    final searchKey = CurrencyData.normalizeCode(trimmed);

    final found = _currencyRates.firstWhere(
      (c) =>
          c.name.toUpperCase() == searchKey ||
          c.code.toUpperCase() == searchKey,
      orElse: () =>
          _localCurrency ??
          (const _CurrencyRate(
            name: 'محلي',
            code: 'LOCAL',
            rate: 1.0,
            isLocal: true,
          )),
    );

    return found.rate;
  }

  void _calculateCurrencySummaries() {
    if (_localCurrency == null || _currencyRates.isEmpty) return;

    final Map<String, _CurrencySummary> summaries = {};

    // حساب المبالغ الفعلية لكل عملة من المعاملات
    final Map<String, Map<String, double>> currencyTotals = {};

    for (final tx in _transactions) {
      final currencyKey = tx.currency.trim();

      if (!currencyTotals.containsKey(currencyKey)) {
        currencyTotals[currencyKey] = {'forMe': 0.0, 'onMe': 0.0};
      }

      if (tx.isForMe) {
        currencyTotals[currencyKey]!['forMe'] =
            (currencyTotals[currencyKey]!['forMe'] ?? 0) + tx.amount;
      } else {
        currencyTotals[currencyKey]!['onMe'] =
            (currencyTotals[currencyKey]!['onMe'] ?? 0) + tx.amount;
      }
    }

    // إضافة جميع العملات المفعلة (من الإعدادات)
    for (final currency in _currencyRates) {
      final currencyKey = currency.name;
      final isLocal = currency.isLocal;
      final key = isLocal ? 'local' : currency.code;

      // البحث عن المبالغ الفعلية لهذه العملة
      double forMe = 0;
      double onMe = 0;

      // البحث في المعاملات عن هذه العملة
      if (currencyTotals.containsKey(currencyKey)) {
        forMe = currencyTotals[currencyKey]!['forMe'] ?? 0;
        onMe = currencyTotals[currencyKey]!['onMe'] ?? 0;
      } else if (currencyTotals.containsKey(currency.code)) {
        forMe = currencyTotals[currency.code]!['forMe'] ?? 0;
        onMe = currencyTotals[currency.code]!['onMe'] ?? 0;
      }

      summaries[key] = _CurrencySummary(
        currencyName: currency.name,
        currencyCode: currency.code,
        emoji: _getEmojiForCurrency(currency.code),
        forMe: forMe,
        onMe: onMe,
        net: forMe - onMe,
        isLocal: isLocal,
      );
    }

    setState(() {
      _currencySummaries = summaries;
      // تعيين العملة المحلية كافتراضية إذا لم تكن محددة
      if (!_currencySummaries.containsKey(_selectedCurrencyCode)) {
        _selectedCurrencyCode = 'local';
      }
    });
  }

  String _getEmojiForCurrency(String code) {
    // تطبيع الكود (التعامل مع الأسماء القديمة)
    final normalizedCode = CurrencyData.normalizeCode(code);

    // محاولة إيجاد العملة في القائمة الشاملة
    try {
      final currency = CurrencyData.all.firstWhere(
        (c) => c.code.toUpperCase() == normalizedCode,
      );
      return currency.flag;
    } catch (_) {
      // إذا لم يتم العثور عليها، نعود للأيقونة الافتراضية
      return '💰';
    }
  }

  double _calculateConvertedTotal(bool isForMe) {
    double total = 0;

    for (final entry in _currencySummaries.entries) {
      final summary = entry.value;
      final value = isForMe ? summary.forMe : summary.onMe;

      if (summary.isLocal) {
        // العملة المحلية - استخدم القيمة مباشرة
        total += value;
      } else {
        // عملة أخرى - حول إلى العملة المحلية
        final rate = _currencyRates
            .firstWhere(
              (c) => c.code == summary.currencyCode,
              orElse: () => _currencyRates.first,
            )
            .rate;
        total += value * rate;
      }
    }

    return total;
  }

  Future<void> _onTransactionLongPress(DebtTransaction tx) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, size: 20),
                  title: Text(
                    AppLocalizations.of(context)!.edit,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();

                    // استخدام مربع الحوار الاحترافي الجديد
                    final result = await AddEditTransactionPage.show(
                      context,
                      initialClient: widget.client,
                      transaction: tx,
                    );

                    if (result == true) {
                      await _loadData();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.delete,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.confirmDelete,
                              style: const TextStyle(fontSize: 16),
                            ),
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.confirmDeleteTransaction,
                              style: const TextStyle(fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (confirm == true) {
                      if (tx.id != null) {
                        await NotificationService.instance.cancelReminder(
                          tx.id!,
                        );
                      }
                      await DebtDatabase.instance.deleteTransaction(tx.id!);
                      await _loadData();
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    final txs = await DebtDatabase.instance.getClientTransactions(
      widget.client.id!,
    );

    double forMe = 0;
    double onMe = 0;
    for (final tx in txs) {
      if (tx.isForMe) {
        forMe += tx.amount;
      } else {
        onMe += tx.amount;
      }
    }

    setState(() {
      _transactions = txs;
      _forMe = forMe;
      _onMe = onMe;
      _loading = false;
    });

    _calculateCurrencySummaries();
    _updatePendingReminderStatus();
  }

  Future<void> _addTransaction() async {
    // استخدام مربع الحوار الاحترافي الجديد
    final added = await AddEditTransactionPage.show(
      context,
      initialClient: widget.client,
    );

    if (added == true) {
      await _loadData();
    }
  }

  Future<void> _editClient() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddEditClientPage(client: widget.client),
      ),
    );

    if (result == true) {
      // إعادة تحميل البيانات
      await _loadData();
      // تحديث عنوان الصفحة (في حالة تغيير الاسم)
      setState(() {});
    }
  }

  /// عرض منتقي التذكير وجدولة الإشعار
  Future<void> _showReminderPicker(DebtTransaction tx) async {
    // اختيار التاريخ
    final pickedDate = await showDatePicker(
      context: context,
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

    if (pickedDate == null || !mounted) return;

    // اختيار الوقت
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF97316)),
        ),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );

    if (pickedTime == null || !mounted) return;

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
      if (mounted) {
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
        client: widget.client,
        scheduledTime: reminderDateTime,
      );

      // 2. تحديث المعاملة في قاعدة البيانات (حفظ وقت التذكير)
      final updatedTx = tx.copyWith(reminderDate: reminderDateTime);
      await DebtDatabase.instance.updateTransaction(updatedTx);

      // 3. تحديث الواجهة
      await _loadData();

      if (mounted) {
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
      if (mounted) {
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

  /// عرض قائمة الديون للتذكير
  void _showAllRemindersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ClientRemindersSheet(
        transactions: _transactions,
        onReschedule: (tx) => _showReminderPicker(tx),
      ),
    );
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientFilterSheet(
        currentCurrencyFilter: _currencyFilter,
        currentTypeFilter: _typeFilter,
        currentDateOrder: _dateOrder,
        availableCurrencies: _currencyRates.map((c) => c.name).toList(),
        onApply: (currency, type, date) {
          setState(() {
            _currencyFilter = currency;
            _typeFilter = type;
            _dateOrder = date;
          });
        },
        onReset: _resetFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            widget.client.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            ClientAppBarActions(
              hasPendingReminder: _hasPendingReminder,
              showConvertedValues: _showConvertedValues,
              onNotificationsPressed: _showAllRemindersSheet,
              onCurrencyTogglePressed: () =>
                  setState(() => _showConvertedValues = !_showConvertedValues),
              onFiltersPressed: _showFiltersSheet,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTransaction,
          child: const Icon(Icons.add),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // بطاقة الملخص الأصلية
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // الصف الأول: له، عليه، الصافي (حسب العملة المختارة أو الإجمالي المحول)
                        Row(
                          children: [
                            Expanded(
                              child: _CompactSummaryItem(
                                icon: Icons.arrow_upward,
                                label: _showConvertedValues
                                    ? l10n.totalForMe
                                    : l10n.forMe,
                                value: _showConvertedValues
                                    ? _calculateConvertedTotal(true)
                                    : (_currencySummaries[_selectedCurrencyCode]
                                              ?.forMe ??
                                          0),
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade200,
                            ),
                            Expanded(
                              child: _CompactSummaryItem(
                                icon: Icons.arrow_downward,
                                label: _showConvertedValues
                                    ? l10n.totalOnMe
                                    : l10n.onMe,
                                value: _showConvertedValues
                                    ? _calculateConvertedTotal(false)
                                    : (_currencySummaries[_selectedCurrencyCode]
                                              ?.onMe ??
                                          0),
                                color: const Color(0xFFEF4444),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade200,
                            ),
                            Expanded(
                              child: _CompactSummaryItem(
                                icon: Icons.account_balance_wallet,
                                label: _showConvertedValues
                                    ? l10n.totalNet
                                    : l10n.net,
                                value: _showConvertedValues
                                    ? (_calculateConvertedTotal(true) -
                                          _calculateConvertedTotal(false))
                                    : (_currencySummaries[_selectedCurrencyCode]
                                              ?.net ??
                                          0),
                                color:
                                    (_showConvertedValues
                                            ? (_calculateConvertedTotal(true) -
                                                  _calculateConvertedTotal(
                                                    false,
                                                  ))
                                            : (_currencySummaries[_selectedCurrencyCode]
                                                      ?.net ??
                                                  0)) >=
                                        0
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),

                        // العملات (جميع العملات بما فيها المحلية)
                        if (_currencySummaries.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _currencySummaries.entries.map((entry) {
                                final summary = entry.value;
                                final isSelected =
                                    _selectedCurrencyCode == entry.key;
                                final isLocal = summary.isLocal;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCurrencyCode = entry.key;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(
                                              0xFF5C6EF8,
                                            ).withOpacity(0.1)
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                      border: isSelected
                                          ? Border.all(
                                              color: const Color(0xFF5C6EF8),
                                              width: 1.5,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          summary.emoji,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_getLocalizedCurrencyName(summary.currencyName)}: ${summary.net.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? const Color(0xFF5C6EF8)
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                        if (isLocal) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              l10n.local,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.orange.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (isSelected && !isLocal) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.check_circle,
                                            size: 14,
                                            color: Color(0xFF5C6EF8),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // بطاقات العملات المحولة (بعد احتساب الصرف)
                  if (_showConvertedValues &&
                      _currencySummaries.length > 1) ...[
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.currency_exchange,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${l10n.convertTo} ${_getLocalizedCurrencyName(_localCurrency?.name ?? l10n.local)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._currencySummaries.entries
                              .where(
                                (e) => !e.value.isLocal && e.value.net != 0,
                              )
                              .map((entry) {
                                final summary = entry.value;
                                final rate = _currencyRates
                                    .firstWhere(
                                      (c) => c.code == summary.currencyCode,
                                      orElse: () => _currencyRates.first,
                                    )
                                    .rate;
                                final convertedValue = summary.net * rate;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        summary.emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade800,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${summary.net.toStringAsFixed(2)} ${_getLocalizedCurrencyName(summary.currencyName)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const TextSpan(text: ' = '),
                                              TextSpan(
                                                text:
                                                    '${convertedValue.toStringAsFixed(2)} ${_getLocalizedCurrencyName(_localCurrency?.name ?? "")}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: convertedValue >= 0
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFEF4444),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '×${rate.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ],
                      ),
                    ),
                  ],

                  // الفلاتر النشطة
                  if (_currencyFilter != 'الكل' ||
                      _typeFilter != 'الكل' ||
                      _dateOrder != 'الأحدث')
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _buildCompactFilters()),
                          TextButton(
                            onPressed: _resetFilters,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text(
                              'مسح',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),

                  // قائمة المعاملات
                  Expanded(
                    child: _transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'لا توجد معاملات',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : Builder(
                            builder: (context) {
                              final filtered = _applyFilters();
                              if (filtered.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'لا توجد معاملات مطابقة',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final tx = filtered[index];
                                  final isForMe = tx.isForMe;
                                  final color = isForMe
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444);
                                  final dateText = _formatDate(tx.date);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onLongPress: () =>
                                        _onTransactionLongPress(tx),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              isForMe
                                                  ? Icons.arrow_upward
                                                  : Icons.arrow_downward,
                                              color: color,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      tx.amount.toStringAsFixed(
                                                        2,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: color,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    _MiniCurrencyBadge(
                                                      currency: tx.currency,
                                                    ),
                                                  ],
                                                ),
                                                if (tx.details.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    tx.details,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 11,
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      dateText,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            dateText,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
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
    final now = DateTime.now();
    final localDate = date.toLocal();
    final diff = now.difference(localDate);

    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return '${diff.inDays} أيام';

    return '${localDate.day}/${localDate.month}';
  }

  void _resetFilters() {
    setState(() {
      _currencyFilter = 'الكل';
      _typeFilter = 'الكل';
      _dateOrder = 'الأحدث';
    });
  }

  Widget _buildCompactFilters() {
    final filters = <String>[];
    if (_currencyFilter != 'الكل') filters.add(_currencyFilter);
    if (_typeFilter != 'الكل') filters.add(_typeFilter);
    if (_dateOrder != 'الأحدث') filters.add(_dateOrder);

    return Text(
      filters.join(' • '),
      style: const TextStyle(fontSize: 12, color: Colors.blue),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<DebtTransaction> _applyFilters() {
    final list = _transactions.where((tx) {
      if (_currencyFilter != 'الكل' && tx.currency != _currencyFilter)
        return false;
      if (_typeFilter == 'له' && !tx.isForMe) return false;
      if (_typeFilter == 'عليه' && tx.isForMe) return false;
      return true;
    }).toList();

    list.sort((a, b) {
      final cmp = a.date.compareTo(b.date);
      return _dateOrder == 'الأقدم' ? cmp : -cmp;
    });

    return list;
  }
}

class _CurrencyRate {
  final String name;
  final String code;
  final double rate;
  final bool isLocal;

  const _CurrencyRate({
    required this.name,
    required this.code,
    required this.rate,
    this.isLocal = false,
  });

  _CurrencyRate copyWith({
    String? name,
    String? code,
    double? rate,
    bool? isLocal,
  }) {
    return _CurrencyRate(
      name: name ?? this.name,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}

class _CurrencySummary {
  final String currencyName;
  final String currencyCode;
  final String emoji;
  final double forMe;
  final double onMe;
  final double net;
  final bool isLocal;

  const _CurrencySummary({
    required this.currencyName,
    required this.currencyCode,
    required this.emoji,
    required this.forMe,
    required this.onMe,
    required this.net,
    this.isLocal = false,
  });
}

class _CompactSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _CompactSummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MiniCurrencyBadge extends StatelessWidget {
  final String currency;

  const _MiniCurrencyBadge({required this.currency});

  @override
  Widget build(BuildContext context) {
    final normalized = currency.trim();
    String emoji;

    try {
      final item = CurrencyData.all.firstWhere(
        (c) =>
            c.code.toUpperCase() == normalized.toUpperCase() ||
            c.name == normalized,
      );
      emoji = item.flag;
    } catch (_) {
      emoji = '💰';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            normalized,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
