import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/debt_database.dart';
import '../../data/currency_data.dart';
import '../../models/client.dart';
import '../../models/transaction.dart';
import '../../l10n/app_localizations.dart';

class AddEditTransactionPage extends StatefulWidget {
  final Client? initialClient;
  final DebtTransaction? transaction;

  const AddEditTransactionPage({
    super.key,
    this.initialClient,
    this.transaction,
  });

  /// عرض مربع حوار إضافة/تعديل دين
  static Future<bool?> show(
    BuildContext context, {
    Client? initialClient,
    DebtTransaction? transaction,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.close,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(curve),
          child: FadeTransition(
            opacity: curve,
            child: _TransactionDialog(
              initialClient: initialClient,
              transaction: transaction,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _CurrencyOption {
  final String code;
  final bool isLocal;
  const _CurrencyOption({required this.code, required this.isLocal});
}

/// مربع حوار أنيق وبسيط
class _TransactionDialog extends StatefulWidget {
  final Client? initialClient;
  final DebtTransaction? transaction;
  const _TransactionDialog({this.initialClient, this.transaction});

  @override
  State<_TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<_TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();

  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  String _currency = '';
  bool _isForMe = true;

  List<Client> _clients = [];
  bool _loading = true;
  List<_CurrencyOption> _currencyOptions = [];
  bool _isSaving = false;

  bool get _isEditMode => widget.transaction != null;

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _amountController.text = widget.transaction!.amount.toString();
      _detailsController.text = widget.transaction!.details;
      _selectedDate = widget.transaction!.date;
      _currency = widget.transaction!.currency;
      _isForMe = widget.transaction!.isForMe;
    }
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final clients = await DebtDatabase.instance.getClients();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('currencies_json');

    List<_CurrencyOption> currencies;
    if (raw == null) {
      currencies = const [
        _CurrencyOption(code: 'YER', isLocal: true),
        _CurrencyOption(code: 'SAR', isLocal: false),
        _CurrencyOption(code: 'USD', isLocal: false),
      ];
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      currencies = decoded
          .where((e) => (e['isActive'] as bool? ?? true))
          .map(
            (e) => _CurrencyOption(
              code: e['code'] ?? 'YER',
              isLocal: e['isLocal'] ?? false,
            ),
          )
          .toList();
      if (currencies.isEmpty) {
        currencies = const [_CurrencyOption(code: 'YER', isLocal: true)];
      }
    }

    Client? selected;
    if (_isEditMode) {
      selected = clients.firstWhere(
        (c) => c.id == widget.transaction!.clientId,
        orElse: () => clients.isNotEmpty ? clients.first : Client(name: ''),
      );
    } else if (widget.initialClient != null) {
      selected = clients.firstWhere(
        (c) => c.id == widget.initialClient!.id,
        orElse: () => widget.initialClient!,
      );
    } else if (clients.isNotEmpty) {
      selected = clients.first;
    }

    // محاولة تطبيع العملة القديمة (الهجرة من الاسم للكود)
    if (_isEditMode && _currency.isNotEmpty) {
      _currency = CurrencyData.normalizeCode(_currency);
    }

    setState(() {
      _clients = clients;
      _selectedClient = selected;
      _currencyOptions = currencies;
      _currency = _isEditMode && _currency.isNotEmpty
          ? _currency
          : currencies
                .firstWhere((c) => c.isLocal, orElse: () => currencies.first)
                .code;

      // التأكد من أن العملة المختارة موجودة في القائمة
      if (!currencies.any((c) => c.code == _currency)) {
        // إذا لم تكن موجودة، نضيفها للقائمة مؤقتاً
        _currencyOptions = [
          ...currencies,
          _CurrencyOption(code: _currency, isLocal: false),
        ];
      }

      _loading = false;
    });
  }

  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.selectClient),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final currentCurrency = _currencyOptions.firstWhere(
        (c) => c.code == _currency,
        orElse: () => _currencyOptions.first,
      );

      final tx = DebtTransaction(
        id: widget.transaction?.id,
        clientId: _selectedClient!.id!,
        amount: amount,
        details: _detailsController.text.trim(),
        date: _selectedDate,
        currency: _currency,
        isLocal: currentCurrency.isLocal,
        isForMe: _isForMe,
        reminderDate: widget.transaction?.reminderDate,
      );

      if (_isEditMode) {
        await DebtDatabase.instance.updateTransaction(tx);
      } else {
        await DebtDatabase.instance.insertTransaction(tx);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.error}: $e'),
            backgroundColor: _red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogWidth = size.width > 420 ? 380.0 : size.width * 0.92;

    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final surfaceColor = isDark
        ? const Color(0xFF2A2A3E)
        : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final activeColor = _isForMe ? _green : _red;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: dialogWidth,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _loading
                ? const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // الرأس
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [activeColor.withOpacity(0.08), bgColor],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: activeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _isEditMode
                                      ? Icons.edit_rounded
                                      : Icons.add_rounded,
                                  color: activeColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isEditMode
                                          ? l10n.editDebt
                                          : l10n.newDebt,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    if (_selectedClient != null)
                                      Text(
                                        _selectedClient!.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: mutedColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // المحتوى
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          child: Column(
                            children: [
                              // نوع الدين
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _typeChip(
                                        l10n.onMe,
                                        l10n.debtOnMe,
                                        Icons.south_rounded,
                                        !_isForMe,
                                        false,
                                        _red,
                                        isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _typeChip(
                                        l10n.forMe,
                                        l10n.debtForMe,
                                        Icons.north_rounded,
                                        _isForMe,
                                        true,
                                        _green,
                                        isDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // المبلغ والعملة
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: activeColor.withOpacity(0.15),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _amountController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: activeColor,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          hintStyle: TextStyle(
                                            color: mutedColor.withOpacity(0.4),
                                            fontSize: 28,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          labelText: l10n.amount,
                                          labelStyle: TextStyle(
                                            fontSize: 12,
                                            color: mutedColor,
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]'),
                                          ),
                                        ],
                                        validator: (v) => v!.isEmpty
                                            ? l10n.amountRequired
                                            : null,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _currency,
                                          isDense: true,
                                          icon: Icon(
                                            Icons.expand_more_rounded,
                                            size: 18,
                                            color: mutedColor,
                                          ),
                                          dropdownColor: bgColor,
                                          focusColor: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          underline: const SizedBox.shrink(),
                                          items: _currencyOptions.map((c) {
                                            final data = CurrencyData.all
                                                .firstWhere(
                                                  (d) => d.code == c.code,
                                                  orElse: () =>
                                                      CurrencyData.all.first,
                                                );
                                            return DropdownMenuItem(
                                              value: c.code,
                                              child: Text(
                                                data.getLocalizedName(context),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: textColor,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (v) =>
                                              setState(() => _currency = v!),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // العميل
                              if (!_isEditMode &&
                                  widget.initialClient == null) ...[
                                _fieldTile(
                                  Icons.person_rounded,
                                  l10n.client,
                                  _selectedClient?.name ?? l10n.chooseClient,
                                  _selectedClient == null,
                                  () => _showClients(
                                    isDark,
                                    bgColor,
                                    textColor,
                                    mutedColor,
                                  ),
                                  mutedColor,
                                  textColor,
                                  surfaceColor,
                                ),
                                const SizedBox(height: 12),
                              ],

                              // التفاصيل
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notes_rounded,
                                      size: 20,
                                      color: mutedColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _detailsController,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: l10n.note,
                                          hintStyle: TextStyle(
                                            color: mutedColor.withOpacity(0.5),
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // التاريخ
                              _fieldTile(
                                Icons.calendar_today_rounded,
                                l10n.date,
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                false,
                                _pickDate,
                                mutedColor,
                                textColor,
                                surfaceColor,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    l10n.change,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _blue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // زر الحفظ
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: activeColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : Text(
                                          _isEditMode ? l10n.save : l10n.add,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(
    String title,
    String sub,
    IconData icon,
    bool isSelected,
    bool isForMeValue,
    Color color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _isForMe = isForMeValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? color
                  : (isDark ? Colors.grey[500] : Colors.grey[400]),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? color
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? color.withOpacity(0.7)
                        : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldTile(
    IconData icon,
    String label,
    String value,
    bool isError,
    VoidCallback onTap,
    Color mutedColor,
    Color textColor,
    Color surfaceColor, {
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: mutedColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: mutedColor),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isError ? _red : textColor,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_left_rounded, size: 20, color: mutedColor),
          ],
        ),
      ),
    );
  }

  void _showClients(
    bool isDark,
    Color bgColor,
    Color textColor,
    Color mutedColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Directionality(
        textDirection: AppLocalizations.of(context)!.localeName.startsWith('ar')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: DraggableScrollableSheet(
          initialChildSize: 0.45,
          maxChildSize: 0.7,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: mutedColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(context)!.selectClient,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _clients.length,
                  itemBuilder: (context, i) {
                    final c = _clients[i];
                    final sel = _selectedClient?.id == c.id;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: sel
                            ? _blue.withOpacity(0.15)
                            : (isDark ? Colors.white12 : Colors.grey[100]),
                        child: Text(
                          c.name.isNotEmpty ? c.name[0] : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: sel ? _blue : mutedColor,
                          ),
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: sel
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: _blue,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedClient = c);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: _blue,
            surface: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        child: Directionality(textDirection: TextDirection.rtl, child: child!),
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
