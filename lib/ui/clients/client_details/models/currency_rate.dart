/// نموذج سعر العملة
class CurrencyRate {
  final String name;
  final String code;
  final double rate;
  final bool isLocal;

  const CurrencyRate({
    required this.name,
    required this.code,
    required this.rate,
    this.isLocal = false,
  });

  CurrencyRate copyWith({
    String? name,
    String? code,
    double? rate,
    bool? isLocal,
  }) {
    return CurrencyRate(
      name: name ?? this.name,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}
