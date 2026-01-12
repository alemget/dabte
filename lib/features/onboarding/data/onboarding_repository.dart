import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/debt_database.dart';
import '../../../models/app_currency.dart';
import '../../../services/currency_settings_service.dart';

class OnboardingRepository {
  Future<void> markCompleted({
    required String userName,
    required AppCurrency primaryCurrency,
    List<AppCurrency> secondaryCurrencies = const [],
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('seen_intro', true);

    if (userName.isNotEmpty) {
      final existing = await DebtDatabase.instance.getProfileInfo();
      await DebtDatabase.instance.saveProfileInfo(
        name: userName,
        phone: (existing?['phone'] as String?) ?? '',
        address: (existing?['address'] as String?) ?? '',
        footer: (existing?['footer'] as String?) ?? '',
      );
    }

    final currencies = <AppCurrency>[
      primaryCurrency.copyWith(isActive: true, isLocal: true),
      ...secondaryCurrencies.map(
        (c) => c.copyWith(isActive: true, isLocal: false),
      ),
    ];

    await CurrencySettingsService().saveCurrencies(currencies);
  }

  Future<Map<String, dynamic>> loadSavedData() async {
    final profile = await DebtDatabase.instance.getProfileInfo();
    final savedCurrencies = await CurrencySettingsService().getAllCurrencies();

    final active = savedCurrencies.where((c) => c.isActive).toList();
    final AppCurrency? primary = active.isEmpty
        ? null
        : active.firstWhere(
            (c) => c.isLocal,
            orElse: () => active.first,
          );

    final secondary = primary == null
        ? const <AppCurrency>[]
        : active.where((c) => c.code != primary.code).toList();

    return {
      'userName': (profile?['name'] as String?) ?? '',
      'primaryCurrency': primary,
      'secondaryCurrencies': secondary,
    };
  }
}
