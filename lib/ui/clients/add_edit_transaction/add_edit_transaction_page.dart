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
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
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

  // ألوان محسنة نفسياً
  static const _greenPrimary = Color(0xFF059669);
  static const _greenLight = Color(0xFF10B981);
  static const _redPrimary = Color(0xFFDC2626);
  static const _redLight = Color(0xFFEF4444);
  static const _purplePrimary = Color(0xFF6366F1);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _detailsFocusNode.addListener(_onNoteFocusChanged);

    if (_isEditMode) {
      _amountController.text = widget.transaction!.amount.toString();
      _detailsController.text = widget.transaction!.details;
      _selectedDate = widget.transaction!.date;
      _currency = widget.transaction!.currency;
      _isForMe = widget.transaction!.isForMe;
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
        backgroundColor: _redPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    // ألوان محسنة
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFBFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final activeColor = _isForMe ? _greenPrimary : _redPrimary;

    return Directionality(
      textDirection: l10n.localeName.startsWith('ar')
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: _purplePrimary,
                  strokeWidth: 3,
                ),
              )
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
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Amount Display
                              _buildAmountDisplay(
                                isDark,
                                cardColor,
                                mutedColor,
                                activeColor,
                              ),
                              const SizedBox(height: 14),

                              // Date Field
                              _buildDateField(
                                l10n,
                                isDark,
                                cardColor,
                                textColor,
                                mutedColor,
                              ),
                              const SizedBox(height: 14),

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

                    // Calculator
                    if (!_isNoteFocused)
                      CalculatorKeyboard(
                        initialValue: _amountController.text,
                        activeColor: activeColor,
                        showDoneButton: true,
                        compactMode: size.height < 700,
                        currencyData: _currencyOptions.map((c) {
                          final currencyInfo = CurrencyData.all.firstWhere(
                            (d) => d.code == c.code,
                            orElse: () => CurrencyData.all.first,
                          );
                          return CurrencyDisplayData(
                            code: c.code,
                            name: currencyInfo.getLocalizedName(context),
                            flag: currencyInfo.flag,
                          );
                        }).toList(),
                        selectedCurrencyCode: _currency,
                        onCurrencyChanged: (code) {
                          setState(() => _currency = code);
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
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
              child: Row(
                children: [
                  // Back button
                  _buildCircleButton(
                    icon: Icons.arrow_back_rounded,
                    color: mutedColor,
                    isDark: isDark,
                    onTap: () => Navigator.pop(context),
                  ),

                  // Title & Client name
                  Expanded(
                    child: Column(
                      children: [
                        if (_selectedClient != null)
                          Text(
                            _selectedClient!.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: mutedColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          _isEditMode ? l10n.editDebt : l10n.newDebt,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Save button
                  _isSaving
                      ? Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: activeColor,
                          ),
                        )
                      : _buildCircleButton(
                          icon: Icons.check_rounded,
                          color: activeColor,
                          isDark: isDark,
                          filled: true,
                          onTap: _handleSave,
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
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // On Me (Red)
                    Expanded(
                      child: _TypeTab(
                        title: l10n.onMe,
                        isSelected: !_isForMe,
                        primaryColor: _redPrimary,
                        secondaryColor: _redLight,
                        isDark: isDark,
                        onTap: () => setState(() => _isForMe = false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // For Me (Green)
                    Expanded(
                      child: _TypeTab(
                        title: l10n.forMe,
                        isSelected: _isForMe,
                        primaryColor: _greenPrimary,
                        secondaryColor: _greenLight,
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

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required bool isDark,
    bool filled = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: filled
              ? color
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: filled ? Colors.white : color, size: 22),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _purplePrimary.withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: _purplePrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: mutedColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: mutedColor.withOpacity(0.5),
              size: 24,
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
    final displayValue = _amountController.text.isEmpty
        ? '0'
        : _amountController.text;

    return GestureDetector(
      onTap: () {
        if (_isNoteFocused) {
          _detailsFocusNode.unfocus();
          setState(() => _isNoteFocused = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: hasValue
              ? LinearGradient(
                  colors: [
                    activeColor.withOpacity(isDark ? 0.15 : 0.08),
                    activeColor.withOpacity(isDark ? 0.08 : 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: hasValue ? null : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasValue
                ? activeColor.withOpacity(0.4)
                : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06)),
            width: hasValue ? 2 : 1,
          ),
          boxShadow: hasValue
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: hasValue ? activeColor : mutedColor.withOpacity(0.4),
                  letterSpacing: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                child: Text(displayValue, textAlign: TextAlign.center),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (hasValue ? activeColor : mutedColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calculate_rounded,
                size: 22,
                color: hasValue ? activeColor : mutedColor.withOpacity(0.5),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isNoteFocused
              ? _purplePrimary.withOpacity(0.5)
              : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06)),
          width: _isNoteFocused ? 2 : 1,
        ),
        boxShadow: _isNoteFocused
            ? [
                BoxShadow(
                  color: _purplePrimary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _purplePrimary.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.notes_rounded, size: 20, color: _purplePrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _detailsController,
              focusNode: _detailsFocusNode,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              textInputAction: TextInputAction.done,
              onEditingComplete: () {
                _detailsFocusNode.unfocus();
              },
              decoration: InputDecoration(
                hintText: '${l10n.note}...',
                hintStyle: TextStyle(
                  color: mutedColor.withOpacity(0.5),
                  fontWeight: FontWeight.w400,
                ),
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
    HapticFeedback.selectionClick();
    _detailsFocusNode.unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: _purplePrimary,
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

/// تبويب نوع الدين المحسن
class _TypeTab extends StatefulWidget {
  final String title;
  final bool isSelected;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeTab({
    required this.title,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_TypeTab> createState() => _TypeTabState();
}

class _TypeTabState extends State<_TypeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [widget.primaryColor, widget.secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isSelected ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : (widget.isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
