/// نموذج بيانات العميل مع ملخص ديونه
/// Data model for client with debt summary
class ClientDebtInfo {
  /// معرف العميل
  final int id;

  /// اسم العميل
  final String name;

  /// رقم الهاتف
  final String? phone;

  /// صافي الديون لكل عملة
  final Map<String, double> netByCurrency;

  /// تاريخ آخر معاملة
  final DateTime? lastTransactionDate;

  const ClientDebtInfo({
    required this.id,
    required this.name,
    this.phone,
    required this.netByCurrency,
    this.lastTransactionDate,
  });

  /// الحصول على إجمالي الدين (للعملة الأساسية أو الأولى)
  double get primaryDebt {
    if (netByCurrency.isEmpty) return 0;
    return netByCurrency.values.first;
  }

  /// الحصول على العملة الأساسية
  String get primaryCurrency {
    if (netByCurrency.isEmpty) return '';
    return netByCurrency.keys.first;
  }

  /// هل العميل عليه دين (لي)
  bool get owesMe => primaryDebt > 0;
}
