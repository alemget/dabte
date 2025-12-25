class ClientNetSummary {
  final int id;
  final String name;
  final String? phone;
  final Map<String, double> netByCurrency;
  final DateTime? lastTransactionDate;

  const ClientNetSummary({
    required this.id,
    required this.name,
    required this.phone,
    required this.netByCurrency,
    required this.lastTransactionDate,
  });

  String? get primaryCurrency {
    if (netByCurrency.isEmpty) return null;

    String? bestCurrency;
    double bestAbs = -1;
    for (final entry in netByCurrency.entries) {
      final absValue = entry.value.abs();
      if (absValue > bestAbs) {
        bestAbs = absValue;
        bestCurrency = entry.key;
      }
    }
    return bestCurrency;
  }

  double? get primaryNet {
    final c = primaryCurrency;
    if (c == null) return null;
    return netByCurrency[c];
  }
}
