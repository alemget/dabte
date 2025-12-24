import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/debt_database.dart';
import '../../data/currency_data.dart';
import '../../l10n/app_localizations.dart';

class CurrenciesPage extends StatefulWidget {
  const CurrenciesPage({super.key});

  @override
  State<CurrenciesPage> createState() => _CurrenciesPageState();
}

class _CurrenciesPageState extends State<CurrenciesPage> {
  List<_Currency> _currencies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('currencies_json');

    List<_Currency> list;
    if (raw == null) {
      // ثلاث عملات افتراضية: يمني (محلي)، سعودي، دولار
      // ثلاث عملات افتراضية: يمني (محلي)، سعودي، دولار
      list = const [
        _Currency(
          name: 'YER',
          code: 'YER',
          rate: 1.0,
          isActive: true,
          isLocal: true,
        ),
        _Currency(
          name: 'SAR',
          code: 'SAR',
          rate: 100.0,
          isActive: true,
          isLocal: false,
        ),
        _Currency(
          name: 'USD',
          code: 'USD',
          rate: 300.0,
          isActive: true,
          isLocal: false,
        ),
      ];
    } else {
      final decoded = jsonDecode(raw) as List<dynamic>;
      list = decoded
          .map(
            (e) => _Currency(
              name: e['name'] as String,
              code: e['code'] as String,
              rate: (e['rate'] as num).toDouble(),
              isActive: e['isActive'] as bool? ?? true,
              isLocal: e['isLocal'] as bool? ?? false,
            ),
          )
          .toList();

      // تأكد أن هناك عملة محلية واحدة على الأقل
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

    setState(() {
      _currencies = list;
      _loading = false;
    });
  }

  Future<void> _saveCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _currencies
        .map(
          (c) => {
            'name': c.name,
            'code': c.code,
            'rate': c.rate,
            'isActive': c.isActive,
            'isLocal': c.isLocal,
          },
        )
        .toList();
    await prefs.setString('currencies_json', jsonEncode(data));
  }

  String _getLocalizedCurrencyName(BuildContext context, _Currency currency) {
    try {
      final data = CurrencyData.all.firstWhere((c) => c.code == currency.code);
      return data.getLocalizedName(context);
    } catch (_) {
      return currency.name;
    }
  }

  Future<void> _editCurrencyRate(_Currency currency) async {
    final controller = TextEditingController(text: currency.rate.toString());
    final formKey = GlobalKey<FormState>();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: Directionality.of(context),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              '${l10n.editCurrency} - ${_getLocalizedCurrencyName(context, currency)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.exchangeRate,
                  hintText: l10n.exchangeRateHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.enterExchangeRate;
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return l10n.enterValidNumberGreaterThanZero;
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      final rate = double.parse(controller.text.trim());
      setState(() {
        _currencies = _currencies
            .map((c) => c.code == currency.code ? c.copyWith(rate: rate) : c)
            .toList();
      });
      await _saveCurrencies();
    }
  }

  Future<void> _setLocalCurrency(_Currency currency) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Directionality(
          textDirection: Directionality.of(context),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.changeLocalCurrency,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: Text(l10n.confirmSetAsLocalCurrency),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _currencies = _currencies
            .map(
              (c) => c.code == currency.code
                  ? c.copyWith(isLocal: true, isActive: true)
                  : c.copyWith(isLocal: false),
            )
            .toList();
      });
      await _saveCurrencies();
    }
  }

  Future<void> _showAddCurrencyDialog() async {
    final nameController = TextEditingController();
    final rateController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedCode;
    final l10n = AppLocalizations.of(context)!;

    // دالة مساعدة لفتح حوار اختيار العملة
    Future<void> selectCurrency() async {
      final CurrencyOption? result = await showDialog<CurrencyOption>(
        context: context,
        builder: (context) => const _CurrencySelectionDialog(),
      );

      if (result != null) {
        nameController.text = result.getLocalizedName(context);
        selectedCode = result.code;
        rateController.text = result.defaultRate.toString();
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: Directionality.of(context),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.addCurrency,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Currency Selection Button
                  InkWell(
                    onTap: selectCurrency,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_exchange,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              nameController.text.isEmpty
                                  ? l10n.chooseCurrencyFromList
                                  : nameController.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: nameController.text.isEmpty
                                    ? Colors.grey.shade600
                                    : Colors.black87,
                                fontWeight: nameController.text.isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rate Input
                  TextFormField(
                    controller: rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: '${l10n.exchangeRate} (${l10n.localCurrency})',
                      hintText: l10n.exchangeRateHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.payments_outlined),
                      suffixText: l10n.perUnit,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.enterExchangeRate;
                      }
                      final parsed = double.tryParse(value.trim());
                      if (parsed == null || parsed <= 0) {
                        return l10n.enterValidNumberGreaterThanZero;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.selectCurrencyFirst)),
                    );
                    return;
                  }
                  if (!formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                ),
                child: Text(l10n.addCurrency),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      final rate = double.parse(rateController.text.trim());
      // إذا لم يتم تحديد الكود (إدخال يدوي مستقبلاً لو أردنا)، نستخدم الاسم ككود مؤقت
      final code =
          selectedCode ?? nameController.text.substring(0, 3).toUpperCase();

      setState(() {
        _currencies.add(
          _Currency(
            name: selectedCode ?? nameController.text.trim(),
            code: code,
            rate: rate,
            isActive: true,
            isLocal: false,
          ),
        );
      });
      await _saveCurrencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localCurrency = _currencies.firstWhere(
      (c) => c.isLocal,
      orElse: () => _currencies.first,
    );
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            l10n.manageCurrencies,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddCurrencyDialog,
          icon: const Icon(Icons.add),
          label: Text(l10n.addCurrency),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _currencies.isEmpty
            ? Center(child: Text(l10n.noCurrencies))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Color(0xFF3B82F6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.howToUse,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.currencyInstructions,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Local Currency Header
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          l10n.localCurrency,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Local Currency Card
                    _CurrencyCard(
                      currency: localCurrency,
                      onEdit: () => _editCurrencyRate(localCurrency),
                      onToggle: null, // Cannot toggle local currency
                      onLongPress: null, // Already local
                    ),

                    const SizedBox(height: 24),

                    // Other Currencies Header
                    Row(
                      children: [
                        Icon(
                          Icons.payments,
                          color: Colors.grey.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.otherCurrencies,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Other Currencies List
                    ..._currencies.where((c) => !c.isLocal).map((currency) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CurrencyCard(
                          currency: currency,
                          onEdit: () => _editCurrencyRate(currency),
                          onToggle: (value) async {
                            if (!value) {
                              // محاولة إيقاف العملة
                              final used = await DebtDatabase.instance
                                  .hasTransactionsWithCurrency(
                                    name: currency.name,
                                  );
                              if (used) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.cannotDeactivateCurrencyWithTransactions,
                                      ),
                                      backgroundColor: Colors.red.shade400,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }
                            }

                            setState(() {
                              _currencies = _currencies
                                  .map(
                                    (cur) => cur.code == currency.code
                                        ? cur.copyWith(isActive: value)
                                        : cur,
                                  )
                                  .toList();
                            });
                            await _saveCurrencies();
                          },
                          onLongPress: () => _setLocalCurrency(currency),
                        ),
                      );
                    }),

                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final _Currency currency;
  final VoidCallback onEdit;
  final Function(bool)? onToggle;
  final VoidCallback? onLongPress;

  const _CurrencyCard({
    required this.currency,
    required this.onEdit,
    this.onToggle,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isLocal = currency.isLocal;
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onEdit,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocal ? Colors.amber.shade200 : Colors.grey.shade200,
            width: isLocal ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLocal
                    ? Colors.amber.withOpacity(0.1)
                    : const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLocal ? Icons.star : Icons.attach_money_rounded,
                color: isLocal
                    ? Colors.amber.shade700
                    : const Color(0xFFF59E0B),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getLocalizedCurrencyName(context, currency),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isLocal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.local,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        currency.code,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        '${l10n.exchangeRate}: ${currency.rate.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (!currency.isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.inactiveCurrency,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Toggle (if allowed)
            if (onToggle != null)
              Switch(
                value: currency.isActive,
                onChanged: onToggle,
                activeColor: Colors.green,
              )
            else
              Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  String _getLocalizedCurrencyName(BuildContext context, _Currency currency) {
    try {
      final data = CurrencyData.all.firstWhere((c) => c.code == currency.code);
      return data.getLocalizedName(context);
    } catch (_) {
      return currency.name;
    }
  }
}

class _Currency {
  final String name;
  final String code;
  final double rate;
  final bool isActive;
  final bool isLocal;

  const _Currency({
    required this.name,
    required this.code,
    required this.rate,
    required this.isActive,
    required this.isLocal,
  });

  _Currency copyWith({
    String? name,
    String? code,
    double? rate,
    bool? isActive,
    bool? isLocal,
  }) {
    return _Currency(
      name: name ?? this.name,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      isActive: isActive ?? this.isActive,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}

class _CurrencySelectionDialog extends StatefulWidget {
  const _CurrencySelectionDialog();

  @override
  State<_CurrencySelectionDialog> createState() =>
      _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<_CurrencySelectionDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = CurrencyData.all.where((c) {
      final name = c.getLocalizedName(context);
      if (_searchQuery.isEmpty) return true;
      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Directionality(
      textDirection: Directionality.of(context),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.selectCurrency,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: l10n.search,
                  hintText: l10n.searchCurrencyOrCode,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(l10n.noResults),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            leading: Text(
                              item.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              item.getLocalizedName(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item.code,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => Navigator.of(context).pop(item),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
