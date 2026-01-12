import 'package:flutter/material.dart';

import '../../../../data/currency_data.dart';
import '../../../../models/app_currency.dart';
import '../../data/onboarding_repository.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  final OnboardingRepository _repository = OnboardingRepository();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  bool _nameReady = false;
  bool get nameReady => _nameReady;

  bool _currencyReady = false;
  bool get currencyReady => _currencyReady;

  bool get canSwipe {
    if (_currentPage == 0) return _nameReady;
    if (_currentPage == 1) return _currencyReady;
    return false;
  }

  List<AppCurrency> _availableCurrencies = [];
  List<AppCurrency> get availableCurrencies => _availableCurrencies;

  AppCurrency? _primaryCurrency;
  AppCurrency? get primaryCurrency => _primaryCurrency;

  String _userName = '';
  String get userName => _userName;

  final List<AppCurrency> _secondaryCurrencies = [];
  List<AppCurrency> get secondaryCurrencies => _secondaryCurrencies;

  OnboardingProvider() {
    _availableCurrencies = CurrencyData.all.map((option) {
      return AppCurrency(
        name: option.name,
        code: option.code,
        rate: option.defaultRate,
        isActive: false,
        isLocal: false,
      );
    }).toList();

    // تحميل البيانات المحفوظة مسبقاً (إن وجدت)
    _loadSavedData();
  }

  /// تحميل البيانات من قاعدة البيانات إذا كانت موجودة
  Future<void> _loadSavedData() async {
    try {
      final data = await _repository.loadSavedData();

      final savedName = data['userName'] as String? ?? '';
      final savedPrimary = data['primaryCurrency'] as AppCurrency?;
      final savedSecondary =
          data['secondaryCurrencies'] as List<AppCurrency>? ?? [];

      if (savedName.isNotEmpty) {
        _userName = savedName;
        _nameReady = true;
      }

      if (savedPrimary != null) {
        _primaryCurrency = savedPrimary;
        _currencyReady = true;
      }

      if (savedSecondary.isNotEmpty) {
        _secondaryCurrencies.addAll(savedSecondary);
      }

      notifyListeners();
    } catch (e) {
      // في حالة وجود خطأ، نتجاهله ونبدأ من الصفر
      debugPrint('OnboardingProvider: Failed to load saved data: $e');
    }
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setNameReady(bool ready) {
    _nameReady = ready;
    notifyListeners();
  }

  void setCurrencyReady(bool ready) {
    _currencyReady = ready;
    notifyListeners();
  }

  void updateUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void selectPrimaryCurrency(AppCurrency currency) {
    _primaryCurrency = currency;
    notifyListeners();
  }

  void addSecondaryCurrency(AppCurrency currency) {
    if (!_secondaryCurrencies.any((c) => c.code == currency.code) &&
        _primaryCurrency?.code != currency.code) {
      _secondaryCurrencies.add(currency);
      notifyListeners();
    }
  }

  void removeSecondaryCurrency(String code) {
    _secondaryCurrencies.removeWhere((c) => c.code == code);
    notifyListeners();
  }

  /// استبدال العملة الفرعية المختارة بعملة جديدة (عملة فرعية واحدة فقط في التهيئة)
  void replaceSecondaryCurrency(AppCurrency currency) {
    if (_primaryCurrency?.code == currency.code) return;
    _secondaryCurrencies.clear();
    _secondaryCurrencies.add(currency);
    notifyListeners();
  }

  Future<void> complete() async {
    final currency = _primaryCurrency;
    if (currency == null) return;

    await _repository.markCompleted(
      userName: _userName,
      primaryCurrency: currency,
      secondaryCurrencies: _secondaryCurrencies,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
