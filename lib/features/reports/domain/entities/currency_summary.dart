class CurrencySummary {
  final String currency;
  final double forMe;
  final double onMe;

  const CurrencySummary({
    required this.currency,
    required this.forMe,
    required this.onMe,
  });

  double get net => forMe - onMe;
}
