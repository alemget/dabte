import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app.dart';
import '../../models/app_currency.dart';

import '../../data/currency_data.dart';

class IntroProvider extends ChangeNotifier {
  final PageController pageController = PageController();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  // Swipe control
  bool _verseReady = false;
  bool get verseReady => _verseReady;

  bool _nameReady = false;
  bool get nameReady => _nameReady;

  bool _currencyReady = false;
  bool get currencyReady => _currencyReady;

  // Can swipe depends on current page state
  bool get canSwipe {
    if (_currentPage == 0) return _verseReady;
    if (_currentPage == 1) return _nameReady;
    if (_currentPage == 2) return _currencyReady;
    return false;
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

  // Currency State
  List<AppCurrency> _availableCurrencies = [];
  List<AppCurrency> get availableCurrencies => _availableCurrencies;

  AppCurrency? _primaryCurrency;
  AppCurrency? get primaryCurrency => _primaryCurrency;

  AppCurrency? _secondaryCurrency;
  AppCurrency? get secondaryCurrency => _secondaryCurrency;

  // Profile State
  String _userName = '';
  String get userName => _userName;

  String _companyName = '';
  String get companyName => _companyName;

  bool _isBackupEnabled = false;
  bool get isBackupEnabled => _isBackupEnabled;

  IntroProvider() {
    _loadCurrencies();
  }

  void _loadCurrencies() {
    // Load from static data
    _availableCurrencies = CurrencyData.all.map((option) {
      return AppCurrency(
        name: option.name,
        code: option.code,
        rate: option.defaultRate,
        isActive: false, // Default to false until selected
        isLocal: false,
      );
    }).toList();
    notifyListeners();
  }

  void setCurrenciesList(List<AppCurrency> currencies) {
    _availableCurrencies = currencies;
    notifyListeners();
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  Future<void> nextPage() async {
    await pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void selectPrimaryCurrency(AppCurrency currency) {
    _primaryCurrency = currency;
    // If same as secondary, clear secondary
    if (_secondaryCurrency?.code == currency.code) {
      _secondaryCurrency = null;
    }
    notifyListeners();
  }

  void selectSecondaryCurrency(AppCurrency currency) {
    // Cannot be same as primary
    if (_primaryCurrency?.code == currency.code) return;

    _secondaryCurrency = currency;
    notifyListeners();
  }

  void toggleSecondaryCurrency(AppCurrency currency) {
    if (_secondaryCurrency?.code == currency.code) {
      _secondaryCurrency = null;
    } else {
      if (_primaryCurrency?.code == currency.code) return;
      _secondaryCurrency = currency;
    }
    notifyListeners();
  }

  void updateProfile({required String name, String? company}) {
    _userName = name;
    _companyName = company ?? '';
    notifyListeners();
  }

  void setBackupEnabled(bool enabled) {
    _isBackupEnabled = enabled;
    notifyListeners();
  }

  Future<void> completeIntro(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_intro', true);

    // Save other settings here (currency, user name, etc)
    if (_primaryCurrency != null) {
      await prefs.setString('currency_code', _primaryCurrency!.code);
      await prefs.setString('currency_name', _primaryCurrency!.name);
      await prefs.setDouble('currency_rate', _primaryCurrency!.rate);
    }

    if (_userName.isNotEmpty) {
      await prefs.setString('user_name', _userName);
    }
    if (_companyName.isNotEmpty) {
      await prefs.setString('company_name', _companyName);
    }

    // Navigate to main app
    if (context.mounted) {
      // Use pushAndRemoveUntil to clear the intro from back stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AppLockWrapper(seenIntro: true),
        ),
        (route) => false,
      );
    }
  }
}
