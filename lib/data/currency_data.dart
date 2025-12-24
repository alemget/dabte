import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CurrencyOption {
  final String name;
  final String code;
  final String flag;
  final double defaultRate;

  const CurrencyOption({
    required this.name,
    required this.code,
    required this.flag,
    this.defaultRate = 1.0,
  });

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      // Arab Currencies
      case 'SAR':
        return l10n.currencySAR;
      case 'AED':
        return l10n.currencyAED;
      case 'KWD':
        return l10n.currencyKWD;
      case 'QAR':
        return l10n.currencyQAR;
      case 'BHD':
        return l10n.currencyBHD;
      case 'OMR':
        return l10n.currencyOMR;
      case 'YER':
        return l10n.currencyYER;
      case 'EGP':
        return l10n.currencyEGP;
      case 'JOD':
        return l10n.currencyJOD;
      case 'LBP':
        return l10n.currencyLBP;
      case 'IQD':
        return l10n.currencyIQD;
      case 'SYP':
        return l10n.currencySYP;
      case 'LYD':
        return l10n.currencyLYD;
      case 'TND':
        return l10n.currencyTND;
      case 'DZD':
        return l10n.currencyDZD;
      case 'MAD':
        return l10n.currencyMAD;
      case 'SDG':
        return l10n.currencySDG;
      // Global Currencies
      case 'USD':
        return l10n.currencyUSD;
      case 'EUR':
        return l10n.currencyEUR;
      case 'GBP':
        return l10n.currencyGBP;
      case 'CNY':
        return l10n.currencyCNY;
      case 'JPY':
        return l10n.currencyJPY;
      case 'TRY':
        return l10n.currencyTRY;
      case 'INR':
        return l10n.currencyINR;
      case 'RUB':
        return l10n.currencyRUB;
      case 'CAD':
        return l10n.currencyCAD;
      case 'AUD':
        return l10n.currencyAUD;
      case 'MYR':
        return l10n.currencyMYR;
      case 'IDR':
        return l10n.currencyIDR;
      // Metals
      case 'GOLD24':
        return l10n.currencyGOLD24;
      case 'GOLD22':
        return l10n.currencyGOLD22;
      case 'GOLD21':
        return l10n.currencyGOLD21;
      case 'GOLD18':
        return l10n.currencyGOLD18;
      default:
        return name;
    }
  }
}

class CurrencyData {
  static const List<CurrencyOption> all = [
    // Arab Currencies
    CurrencyOption(
      name: 'ريال سعودي',
      code: 'SAR',
      flag: '🇸🇦',
      defaultRate: 100,
    ),
    CurrencyOption(
      name: 'درهم إماراتي',
      code: 'AED',
      flag: '🇦🇪',
      defaultRate: 100,
    ),
    CurrencyOption(
      name: 'دينار كويتي',
      code: 'KWD',
      flag: '🇰🇼',
      defaultRate: 1200,
    ),
    CurrencyOption(
      name: 'ريال قطري',
      code: 'QAR',
      flag: '🇶🇦',
      defaultRate: 100,
    ),
    CurrencyOption(
      name: 'دينار بحريني',
      code: 'BHD',
      flag: '🇧🇭',
      defaultRate: 1000,
    ),
    CurrencyOption(
      name: 'ريال عماني',
      code: 'OMR',
      flag: '🇴🇲',
      defaultRate: 1000,
    ),
    CurrencyOption(
      name: 'ريال يمني',
      code: 'YER',
      flag: '🇾🇪',
      defaultRate: 1,
    ),
    CurrencyOption(
      name: 'جنيه مصري',
      code: 'EGP',
      flag: '🇪🇬',
      defaultRate: 10,
    ),
    CurrencyOption(
      name: 'دينار أردني',
      code: 'JOD',
      flag: '🇯🇴',
      defaultRate: 500,
    ),
    CurrencyOption(
      name: 'ليرة لبنانية',
      code: 'LBP',
      flag: '🇱🇧',
      defaultRate: 0.01,
    ),
    CurrencyOption(
      name: 'دينار عراقي',
      code: 'IQD',
      flag: '🇮🇶',
      defaultRate: 0.3,
    ),
    CurrencyOption(
      name: 'ليرة سورية',
      code: 'SYP',
      flag: '🇸🇾',
      defaultRate: 0.1,
    ),
    CurrencyOption(
      name: 'دينار ليبي',
      code: 'LYD',
      flag: '🇱🇾',
      defaultRate: 80,
    ),
    CurrencyOption(
      name: 'دينار تونسي',
      code: 'TND',
      flag: '🇹🇳',
      defaultRate: 120,
    ),
    CurrencyOption(
      name: 'دينار جزائري',
      code: 'DZD',
      flag: '🇩🇿',
      defaultRate: 3,
    ),
    CurrencyOption(
      name: 'درهم مغربي',
      code: 'MAD',
      flag: '🇲🇦',
      defaultRate: 35,
    ),
    CurrencyOption(
      name: 'جنيه سوداني',
      code: 'SDG',
      flag: '🇸🇩',
      defaultRate: 0.5,
    ),

    // Global Currencies
    CurrencyOption(
      name: 'دولار أمريكي',
      code: 'USD',
      flag: '🇺🇸',
      defaultRate: 375,
    ),
    CurrencyOption(name: 'يورو', code: 'EUR', flag: '🇪🇺', defaultRate: 400),
    CurrencyOption(
      name: 'جنيه إسترليني',
      code: 'GBP',
      flag: '🇬🇧',
      defaultRate: 450,
    ),
    CurrencyOption(
      name: 'يوان صيني',
      code: 'CNY',
      flag: '🇨🇳',
      defaultRate: 50,
    ),
    CurrencyOption(
      name: 'ين ياباني',
      code: 'JPY',
      flag: '🇯🇵',
      defaultRate: 3,
    ),
    CurrencyOption(
      name: 'ليرة تركية',
      code: 'TRY',
      flag: '🇹🇷',
      defaultRate: 15,
    ),
    CurrencyOption(
      name: 'روبية هندية',
      code: 'INR',
      flag: '🇮🇳',
      defaultRate: 5,
    ),
    CurrencyOption(
      name: 'روبل روسي',
      code: 'RUB',
      flag: '🇷🇺',
      defaultRate: 4,
    ),
    CurrencyOption(
      name: 'دولار كندي',
      code: 'CAD',
      flag: '🇨🇦',
      defaultRate: 280,
    ),
    CurrencyOption(
      name: 'دولار أسترالي',
      code: 'AUD',
      flag: '🇦🇺',
      defaultRate: 250,
    ),
    CurrencyOption(
      name: 'رينغيت ماليزي',
      code: 'MYR',
      flag: '🇲🇾',
      defaultRate: 85,
    ),
    CurrencyOption(
      name: 'روبية إندونيسية',
      code: 'IDR',
      flag: '🇮🇩',
      defaultRate: 0.02,
    ),

    // Metals (Gold)
    CurrencyOption(
      name: 'ذهب عيار 24',
      code: 'GOLD24',
      flag: '�',
      defaultRate: 0,
    ),
    CurrencyOption(
      name: 'ذهب عيار 22',
      code: 'GOLD22',
      flag: '�',
      defaultRate: 0,
    ),
    CurrencyOption(
      name: 'ذهب عيار 21',
      code: 'GOLD21',
      flag: '�',
      defaultRate: 0,
    ),
    CurrencyOption(
      name: 'ذهب عيار 18',
      code: 'GOLD18',
      flag: '�',
      defaultRate: 0,
    ),
  ];

  /// Normalize currency code/name to a standard code (e.g. 'يمني' -> 'YER')
  static String normalizeCode(String input) {
    if (input.isEmpty) return 'YER'; // Default fallback

    final normalized = input.toUpperCase().trim();

    // Handle legacy Arabic names
    if (normalized == 'يمني' || normalized == 'ريال يمني') return 'YER';
    if (normalized == 'سعودي' || normalized == 'ريال سعودي') return 'SAR';
    if (normalized == 'دولار' || normalized == 'دولار أمريكي') return 'USD';

    return normalized;
  }
}
