import 'package:flutter/material.dart';

import '../../../../data/currency_data.dart';
import '../../../../models/app_currency.dart';
import '../../data/onboarding_repository.dart';

class OnboardingProvider extends ChangeNotifier {
  final PageController pageController = PageController();
  final OnboardingRepository _repository = OnboardingRepository();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  bool _verseReady = false;
  bool get verseReady => _verseReady;

  bool _nameReady = false;
  bool get nameReady => _nameReady;

  bool _currencyReady = false;
  bool get currencyReady => _currencyReady;

  bool get canSwipe {
    if (_currentPage == 0) return _verseReady;
    if (_currentPage == 1) return _nameReady;
    if (_currentPage == 2) return _currencyReady;
    return false;
  }

  List<AppCurrency> _availableCurrencies = [];
  List<AppCurrency> get availableCurrencies => _availableCurrencies;

  AppCurrency? _primaryCurrency;
  AppCurrency? get primaryCurrency => _primaryCurrency;

  String _userName = '';
  String get userName => _userName;

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
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setVerseReady(bool ready) {
    _verseReady = ready;
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

  Future<void> complete() async {
    final currency = _primaryCurrency;
    if (currency == null) return;

    await _repository.markCompleted(
      userName: _userName,
      primaryCurrency: currency,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
