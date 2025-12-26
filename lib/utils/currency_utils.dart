class CurrencyUtils {
  static String normalizeCode(String input) {
    if (input.isEmpty) return 'YER';

    final normalized = input.toUpperCase().trim();

    if (normalized == 'يمني' || normalized == 'ريال يمني') return 'YER';
    if (normalized == 'سعودي' || normalized == 'ريال سعودي') return 'SAR';
    if (normalized == 'دولار' || normalized == 'دولار أمريكي') return 'USD';

    return normalized;
  }

  static List<String> aliasesForCode(String code) {
    final normalized = normalizeCode(code);

    switch (normalized) {
      case 'YER':
        return const ['YER', 'يمني', 'ريال يمني'];
      case 'SAR':
        return const ['SAR', 'سعودي', 'ريال سعودي'];
      case 'USD':
        return const ['USD', 'دولار', 'دولار أمريكي'];
      default:
        return [normalized];
    }
  }
}
