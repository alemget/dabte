/// نموذج ملخص العملة
class CurrencySummary {
  final String currencyName;
  final String currencyCode;
  final String emoji;
  final double forMe;
  final double onMe;
  final double net;
  final bool isLocal;

  const CurrencySummary({
    required this.currencyName,
    required this.currencyCode,
    required this.emoji,
    required this.forMe,
    required this.onMe,
    required this.net,
    this.isLocal = false,
  });
}
