class AppCurrency {
  final String name;
  final String code;
  final double rate;
  final bool isActive;
  final bool isLocal;

  const AppCurrency({
    required this.name,
    required this.code,
    required this.rate,
    this.isActive = true,
    this.isLocal = false,
  });

  AppCurrency copyWith({
    String? name,
    String? code,
    double? rate,
    bool? isActive,
    bool? isLocal,
  }) {
    return AppCurrency(
      name: name ?? this.name,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      isActive: isActive ?? this.isActive,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'rate': rate,
      'isActive': isActive,
      'isLocal': isLocal,
    };
  }

  factory AppCurrency.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] as String?) ?? '';
    final code = (json['code'] as String?) ?? '';

    return AppCurrency(
      name: name,
      code: code,
      rate: (json['rate'] as num?)?.toDouble() ?? 1.0,
      isActive: json['isActive'] as bool? ?? true,
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }
}
