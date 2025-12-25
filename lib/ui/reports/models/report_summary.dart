/// نموذج بيانات ملخص التقارير
/// Data model for report summary statistics
class ReportSummary {
  /// إجمالي المبالغ المستحقة لي
  final Map<String, double> totalForMe;

  /// إجمالي المبالغ المستحقة عليّ
  final Map<String, double> totalOnMe;

  /// صافي الحساب لكل عملة
  final Map<String, double> netBalance;

  /// إجمالي عدد العملاء
  final int totalClients;

  /// عدد العملاء الذين لديهم ديون
  final int clientsWithDebts;

  /// عدد المعاملات
  final int totalTransactions;

  const ReportSummary({
    required this.totalForMe,
    required this.totalOnMe,
    required this.netBalance,
    required this.totalClients,
    required this.clientsWithDebts,
    required this.totalTransactions,
  });

  /// إنشاء نموذج فارغ
  factory ReportSummary.empty() => const ReportSummary(
    totalForMe: {},
    totalOnMe: {},
    netBalance: {},
    totalClients: 0,
    clientsWithDebts: 0,
    totalTransactions: 0,
  );
}
