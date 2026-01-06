import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/app_currency.dart';

class OnboardingRepository {
  Future<void> markCompleted({
    required String userName,
    required AppCurrency primaryCurrency,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('seen_intro', true);

    if (userName.isNotEmpty) {
      await prefs.setString('user_name', userName);
    }

    await prefs.setString('currency_code', primaryCurrency.code);
    await prefs.setString('currency_name', primaryCurrency.name);
    await prefs.setDouble('currency_rate', primaryCurrency.rate);
  }
}
