import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/debt_database.dart';
import '../../../data/currency_data.dart' hide CurrencyOption;
import '../../../models/client.dart';
import '../../../models/transaction.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/widgets.dart';
import 'models/currency_option.dart';

class AddEditTransactionPage extends StatefulWidget {
  final Client? initialClient;
  final DebtTransaction? transaction;

  const AddEditTransactionPage({
    super.key,
    this.initialClient,
    this.transaction,
  });

  /// عرض صفحة إضافة/تعديل دين
  static Future<bool?> show(
    BuildContext context, {
    Client? initialClient,
    DebtTransaction? transaction,
  }) async {
    // للديون الجديدة فقط: عرض مربع اختيار النوع أولاً
    bool? selectedType;
    if (transaction == null) {
      selectedType = await DebtTypeSelectorDialog.show(context);
      if (selectedType == null) return null;
    }

    return Navigator.of(context).push<bool>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _TransactionPage(
              initialClient: initialClient,
              transaction: transaction,
              preSelectedType: selectedType,
            ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(curve),
            child: FadeTransition(opacity: curve, child: child),
          );
        },
      ),
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

/// صفحة المعاملة الكاملة
class _TransactionPage extends StatefulWidget {
  final Client? initialClient;
  final DebtTransaction? transaction;
  final bool? preSelectedType;

  const _TransactionPage({
    this.initialClient,
    this.transaction,
    this.preSelectedType,
  });

  @override
  State<_TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<_TransactionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  final _detailsFocusNode = FocusNode();

  Client? _selectedClient;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _reminderTime;
  String _currency = '';
  bool _isForMe = true;

  List<Client> _clients = [];
  bool _loading = true;
  List<CurrencyOption> _currencyOptions = [];
  bool _isSaving = false;
  bool _isNoteFocused = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditMode => widget.transaction != null;

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    // Listen to note focus changes
    _detailsFocusNode.addListener(_onNoteFocusChanged);

    if (_isEditMode) {
      _amountController.text = widget.transaction!.amount.toString();
      _detailsController.text = widget.transaction!.details;
      _selectedDate = widget.transaction!.date;
      _currency = widget.transaction!.currency;
      _isForMe = widget.transaction!.isForMe;
      // Initialize reminder time if exists
      if (widget.transaction!.reminderDate != null) {
        _reminderTime = TimeOfDay.fromDateTime(
          widget.transaction!.reminderDate!,
        );
      }
    } else if (widget.preSelectedType != null) {
      _isForMe = widget.preSelectedType!;
    }
    _loadData();
  }

  void _onNoteFocusChanged() {
    setState(() {
      _isNoteFocused = _detailsFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _detailsFocusNode.removeListener(_onNoteFocusChanged);
    _amountController.dispose();
    _detailsController.dispose();
    _detailsFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final clients = await DebtDatabase.instance.getClients();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('currencies_json');

    List<CurrencyOption> currencies;
    if (raw == null) {
      currencies = const [];
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      currencies = decoded
          .where((e) => (e['isActive'] as bool? ?? true))
          .map(
            (e) => CurrencyOption(
              code: e['code'] ?? 'YER',
              isLocal: e['isLocal'] ?? false,
            ),
          )
          .toList();
      if (currencies.isEmpty) {
        currencies = const [CurrencyOption(code: 'YER', isLocal: true)];
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

      if (!currencies.any((c) => c.code == _currency)) {
        _currencyOptions = [
          ...currencies,
          CurrencyOption(code: _currency, isLocal: false),
        ];
      }

      _loading = false;
    });
    _animController.forward();
  }

  Future<void> _handleSave() async {
    HapticFeedback.mediumImpact();

    // Validate amount
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty ||
        double.tryParse(amountText) == null ||
        double.parse(amountText) <= 0) {
      _showError(AppLocalizations.of(context)!.enterAmount);
      return;
    }

    if (_selectedClient == null) {
      _showError(AppLocalizations.of(context)!.selectClient);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final amount = double.parse(amountText);
      final currentCurrency = _currencyOptions.firstWhere(
        (c) => c.code == _currency,
        orElse: () => _currencyOptions.first,
      );

      DateTime? reminderDate;
      if (_reminderTime != null) {
        reminderDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _reminderTime!.hour,
          _reminderTime!.minute,
        );
      }

      final tx = DebtTransaction(
        id: widget.transaction?.id,
        clientId: _selectedClient!.id!,
        amount: amount,
        details: _detailsController.text.trim(),
        date: _selectedDate,
        currency: _currency,
        isLocal: currentCurrency.isLocal,
        isForMe: _isForMe,
        reminderDate: reminderDate,
      );

      if (_isEditMode) {
        await DebtDatabase.instance.updateTransaction(tx);
      } else {
        await DebtDatabase.instance.insertTransaction(tx);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        _showError('${AppLocalizations.of(context)!.error}: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final bgColor = isDark ? const Color(0xFF121220) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final mutedColor = isDark ? Colors.grey[400]! : const Color(0xFF64748B);
    final activeColor = _isForMe ? _green : _red;

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    // Header
                    _buildHeader(
                      l10n,
                      isDark,
                      cardColor,
                      textColor,
                      mutedColor,
                      activeColor,
                    ),

                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Date Field
                              _buildDateField(
                                l10n,
                                isDark,
                                cardColor,
                                textColor,
                                mutedColor,
                              ),
                              const SizedBox(height: 12),

                              // Amount Display
                              _buildAmountDisplay(
                                isDark,
                                cardColor,
                                mutedColor,
                                activeColor,
                              ),
                              const SizedBox(height: 12),

                              // Note Field
                              _buildNoteField(
                                l10n,
                                isDark,
                                cardColor,
                                textColor,
                                mutedColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Calculator - hide when note field is focused
                    if (!_isNoteFocused)
                      CalculatorKeyboard(
                        initialValue: _amountController.text,
                        activeColor: activeColor,
                        showDoneButton: true,
                        compactMode: size.height < 700,
                        currencies: _currencyOptions
                            .map(
                              (c) => CurrencyData.all
                                  .firstWhere(
                                    (d) => d.code == c.code,
                                    orElse: () => CurrencyData.all.first,
                                  )
                                  .getLocalizedName(context),
                            )
                            .toList(),
                        selectedCurrency: CurrencyData.all
                            .firstWhere(
                              (d) => d.code == _currency,
                              orElse: () => CurrencyData.all.first,
                            )
                            .getLocalizedName(context),
                        onCurrencyChanged: (name) {
                          final currency = _currencyOptions.firstWhere(
                            (c) =>
                                CurrencyData.all
                                    .firstWhere(
                                      (d) => d.code == c.code,
                                      orElse: () => CurrencyData.all.first,
                                    )
                                    .getLocalizedName(context) ==
                                name,
                            orElse: () => _currencyOptions.first,
                          );
                          setState(() => _currency = currency.code);
                        },
                        onValueChanged: (value) {
                          setState(() {
                            _amountController.text = value;
                          });
                        },
                        onDone: _handleSave,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(
    AppLocalizations l10n,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
    Color activeColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_rounded, color: textColor),
                  ),

                  // Title & Client name
                  Expanded(
                    child: Column(
                      children: [
                        if (_selectedClient != null)
                          Text(
                            _selectedClient!.name,
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                        Text(
                          _isEditMode ? l10n.editDebt : l10n.newDebt,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Save button
                  _isSaving
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          onPressed: _handleSave,
                          icon: Icon(
                            Icons.check_rounded,
                            color: activeColor,
                            size: 28,
                          ),
                        ),
                ],
              ),
            ),

            // Type Tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF252540)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    // On Me (Red)
                    Expanded(
                      child: _TypeTab(
                        title: l10n.onMe,
                        isSelected: !_isForMe,
                        color: _red,
                        isDark: isDark,
                        onTap: () => setState(() => _isForMe = false),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // For Me (Green)
                    Expanded(
                      child: _TypeTab(
                        title: l10n.forMe,
                        isSelected: _isForMe,
                        color: _green,
                        isDark: isDark,
                        onTap: () => setState(() => _isForMe = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    AppLocalizations l10n,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
  ) {
    final dayName = _getDayName(_selectedDate);

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 20, color: mutedColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ($dayName)',
                style: TextStyle(fontSize: 15, color: textColor),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: mutedColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(
    bool isDark,
    Color cardColor,
    Color mutedColor,
    Color activeColor,
  ) {
    final hasValue = _amountController.text.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (_isNoteFocused) {
          // Unfocus note to dismiss native keyboard and show calculator
          _detailsFocusNode.unfocus();
          setState(() => _isNoteFocused = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue
                ? activeColor.withOpacity(0.4)
                : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06)),
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _amountController.text.isEmpty ? '0' : _amountController.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: hasValue ? activeColor : mutedColor.withOpacity(0.4),
                  letterSpacing: 1,
                ),
              ),
            ),
            Icon(
              Icons.calculate_rounded,
              size: 24,
              color: mutedColor.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField(
    AppLocalizations l10n,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color mutedColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.notes_rounded, size: 20, color: mutedColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _detailsController,
              focusNode: _detailsFocusNode,
              style: TextStyle(fontSize: 15, color: textColor),
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                _detailsFocusNode.unfocus();
              },
              decoration: InputDecoration(
                hintText: '${l10n.note}...',
                hintStyle: TextStyle(color: mutedColor.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.localeName.startsWith('ar');

    final daysAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    final daysEn = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final dayIndex = date.weekday % 7;
    return isArabic ? daysAr[dayIndex] : daysEn[dayIndex];
  }

  Future<void> _pickDate() async {
    _detailsFocusNode.unfocus();

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
        child: Directionality(
          textDirection:
              AppLocalizations.of(context)!.localeName.startsWith('ar')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        ),
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}

/// تبويب نوع الدين
class _TypeTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeTab({
    required this.title,
    required this.isSelected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
