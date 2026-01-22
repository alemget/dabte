import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/currency_data.dart';
import '../models/app_currency.dart';

class CurrencySettingsService {
  static const String _prefsKey = 'currencies_json';

  Future<List<AppCurrency>> getAllCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null) {
      return const [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final parsed = decoded
        .whereType<Map>()
        .map((e) => AppCurrency.fromJson(Map<String, dynamic>.from(e)))
        .map(_normalize)
        .toList();

    return _ensureSingleLocal(parsed);
  }

  Future<List<AppCurrency>> getActiveCurrencies() async {
    final all = await getAllCurrencies();
    final active = all.where((c) => c.isActive).toList();
    return active.isEmpty
        ? const [
            AppCurrency(
              name: 'YER',
              code: 'YER',
              rate: 1.0,
              isActive: true,
              isLocal: true,
            ),
          ]
        : active;
  }

  Future<AppCurrency> getLocalCurrency() async {
    final list = await getActiveCurrencies();
    return list.firstWhere((c) => c.isLocal, orElse: () => list.first);
  }

  Future<void> saveCurrencies(List<AppCurrency> currencies) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _ensureSingleLocal(currencies.map(_normalize).toList());
    final data = normalized.map((c) => c.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  AppCurrency _normalize(AppCurrency currency) {
    final normalizedCode = CurrencyData.normalizeCode(
      currency.code.isNotEmpty ? currency.code : currency.name,
    );

    return currency.copyWith(code: normalizedCode, name: normalizedCode);
  }

  List<AppCurrency> _ensureSingleLocal(List<AppCurrency> list) {
    if (list.isEmpty) return list;
    if (list.where((c) => c.isLocal).length == 1) return list;

    final preferred = list.any((c) => c.code == 'YER')
        ? 'YER'
        : list.first.code;

    return list.map((c) => c.copyWith(isLocal: c.code == preferred)).toList();
  }
}
