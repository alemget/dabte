/// نموذج توزيع العملات
/// Data model for currency breakdown
class CurrencyBreakdown {
  /// اسم/رمز العملة
  final String currency;

  /// إجمالي المبالغ "لي"
  final double forMe;

  /// إجمالي المبالغ "عليّ"
  final double onMe;

  const CurrencyBreakdown({
    required this.currency,
    required this.forMe,
    required this.onMe,
  });

  /// صافي الحساب
  double get net => forMe - onMe;

  /// هل الصافي إيجابي (لي)
  bool get isPositive => net > 0;

  /// هل الصافي سلبي (عليّ)
  bool get isNegative => net < 0;

  /// القيمة المطلقة للصافي
  double get absoluteNet => net.abs();
}
