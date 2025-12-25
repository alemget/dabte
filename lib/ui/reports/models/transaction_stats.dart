/// نموذج إحصائيات المعاملات
/// Data model for transaction statistics
class TransactionStats {
  /// عدد المعاملات الإجمالي
  final int totalCount;

  /// عدد معاملات "لي"
  final int forMeCount;

  /// عدد معاملات "عليّ"
  final int onMeCount;

  /// إجمالي مبالغ "لي"
  final double forMeTotal;

  /// إجمالي مبالغ "عليّ"
  final double onMeTotal;

  /// عدد معاملات هذا الأسبوع
  final int thisWeekCount;

  /// عدد معاملات هذا الشهر
  final int thisMonthCount;

  const TransactionStats({
    required this.totalCount,
    required this.forMeCount,
    required this.onMeCount,
    required this.forMeTotal,
    required this.onMeTotal,
    required this.thisWeekCount,
    required this.thisMonthCount,
  });

  /// نسبة معاملات "لي"
  double get forMePercentage {
    if (totalCount == 0) return 0;
    return (forMeCount / totalCount) * 100;
  }

  /// نسبة معاملات "عليّ"
  double get onMePercentage {
    if (totalCount == 0) return 0;
    return (onMeCount / totalCount) * 100;
  }

  /// إنشاء نموذج فارغ
  factory TransactionStats.empty() => const TransactionStats(
    totalCount: 0,
    forMeCount: 0,
    onMeCount: 0,
    forMeTotal: 0,
    onMeTotal: 0,
    thisWeekCount: 0,
    thisMonthCount: 0,
  );
}
