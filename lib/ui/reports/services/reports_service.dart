import '../../../data/debt_database.dart';
import '../models/models.dart';

/// خدمة جلب بيانات التقارير من قاعدة البيانات
/// Service for fetching reports data from database
class ReportsService {
  final DebtDatabase _db = DebtDatabase.instance;

  /// جلب ملخص التقارير الشامل
  Future<ReportSummary> getReportSummary() async {
    final db = await _db.database;

    // جلب إحصائيات العملاء
    final clientsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM clients',
    );
    final totalClients = clientsResult.first['count'] as int? ?? 0;

    // جلب عدد العملاء الذين لديهم معاملات
    final clientsWithDebtsResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT clientId) as count FROM transactions
    ''');
    final clientsWithDebts = clientsWithDebtsResult.first['count'] as int? ?? 0;

    // جلب عدد المعاملات
    final transactionsResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions',
    );
    final totalTransactions = transactionsResult.first['count'] as int? ?? 0;

    // جلب المجاميع حسب العملة والنوع
    final summaryResult = await db.rawQuery('''
      SELECT currency, isForMe, SUM(amount) as total
      FROM transactions
      GROUP BY currency, isForMe
    ''');

    final Map<String, double> totalForMe = {};
    final Map<String, double> totalOnMe = {};
    final Map<String, double> netBalance = {};

    for (final row in summaryResult) {
      final currency = row['currency'] as String;
      final isForMe = (row['isForMe'] as int) == 1;
      final total = (row['total'] as num?)?.toDouble() ?? 0;

      if (isForMe) {
        totalForMe[currency] = (totalForMe[currency] ?? 0) + total;
      } else {
        totalOnMe[currency] = (totalOnMe[currency] ?? 0) + total;
      }
    }

    // حساب الصافي
    final allCurrencies = {...totalForMe.keys, ...totalOnMe.keys};
    for (final currency in allCurrencies) {
      final forMe = totalForMe[currency] ?? 0;
      final onMe = totalOnMe[currency] ?? 0;
      netBalance[currency] = forMe - onMe;
    }

    return ReportSummary(
      totalForMe: totalForMe,
      totalOnMe: totalOnMe,
      netBalance: netBalance,
      totalClients: totalClients,
      clientsWithDebts: clientsWithDebts,
      totalTransactions: totalTransactions,
    );
  }

  /// جلب أكثر العملاء ديوناً
  Future<List<ClientDebtInfo>> getTopDebtors({int limit = 5}) async {
    final db = await _db.database;

    final result = await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        c.phone,
        t.currency,
        t.isForMe,
        SUM(t.amount) as total,
        MAX(t.date) as lastDate
      FROM clients c
      LEFT JOIN transactions t ON c.id = t.clientId
      WHERE t.id IS NOT NULL
      GROUP BY c.id, t.currency, t.isForMe
      ORDER BY c.name
    ''');

    // تجميع البيانات حسب العميل
    final Map<int, ClientDebtInfo> clientsMap = {};

    for (final row in result) {
      final clientId = row['id'] as int;
      final currency = row['currency'] as String?;
      final isForMe = (row['isForMe'] as int?) == 1;
      final total = (row['total'] as num?)?.toDouble() ?? 0;
      final lastDate = row['lastDate'] as String?;

      if (!clientsMap.containsKey(clientId)) {
        clientsMap[clientId] = ClientDebtInfo(
          id: clientId,
          name: row['name'] as String,
          phone: row['phone'] as String?,
          netByCurrency: {},
          lastTransactionDate: lastDate != null
              ? DateTime.tryParse(lastDate)
              : null,
        );
      }

      if (currency != null) {
        final currentNet = clientsMap[clientId]!.netByCurrency[currency] ?? 0;
        // تحديث الصافي - باستخدام Map جديد لأن الحقل final
        final updatedNet = Map<String, double>.from(
          clientsMap[clientId]!.netByCurrency,
        );
        updatedNet[currency] = currentNet + (isForMe ? total : -total);

        clientsMap[clientId] = ClientDebtInfo(
          id: clientId,
          name: clientsMap[clientId]!.name,
          phone: clientsMap[clientId]!.phone,
          netByCurrency: updatedNet,
          lastTransactionDate: clientsMap[clientId]!.lastTransactionDate,
        );
      }
    }

    // ترتيب حسب أعلى دين وإرجاع العدد المطلوب
    final clientsList = clientsMap.values.toList();
    clientsList.sort(
      (a, b) => b.primaryDebt.abs().compareTo(a.primaryDebt.abs()),
    );

    return clientsList.take(limit).toList();
  }

  /// جلب إحصائيات المعاملات
  Future<TransactionStats> getTransactionStats() async {
    final db = await _db.database;

    // إجمالي المعاملات
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalCount,
        SUM(CASE WHEN isForMe = 1 THEN 1 ELSE 0 END) as forMeCount,
        SUM(CASE WHEN isForMe = 0 THEN 1 ELSE 0 END) as onMeCount,
        SUM(CASE WHEN isForMe = 1 THEN amount ELSE 0 END) as forMeTotal,
        SUM(CASE WHEN isForMe = 0 THEN amount ELSE 0 END) as onMeTotal
      FROM transactions
    ''');

    final row = result.first;
    final totalCount = (row['totalCount'] as int?) ?? 0;
    final forMeCount = (row['forMeCount'] as int?) ?? 0;
    final onMeCount = (row['onMeCount'] as int?) ?? 0;
    final forMeTotal = (row['forMeTotal'] as num?)?.toDouble() ?? 0;
    final onMeTotal = (row['onMeTotal'] as num?)?.toDouble() ?? 0;

    // معاملات هذا الأسبوع
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = weekStart.toIso8601String().split('T')[0];

    final weekResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM transactions
      WHERE date >= ?
    ''',
      [weekStartStr],
    );
    final thisWeekCount = (weekResult.first['count'] as int?) ?? 0;

    // معاملات هذا الشهر
    final monthStart = DateTime(now.year, now.month, 1);
    final monthStartStr = monthStart.toIso8601String().split('T')[0];

    final monthResult = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM transactions
      WHERE date >= ?
    ''',
      [monthStartStr],
    );
    final thisMonthCount = (monthResult.first['count'] as int?) ?? 0;

    return TransactionStats(
      totalCount: totalCount,
      forMeCount: forMeCount,
      onMeCount: onMeCount,
      forMeTotal: forMeTotal,
      onMeTotal: onMeTotal,
      thisWeekCount: thisWeekCount,
      thisMonthCount: thisMonthCount,
    );
  }

  /// جلب توزيع العملات
  Future<List<CurrencyBreakdown>> getCurrencyBreakdown() async {
    final db = await _db.database;

    final result = await db.rawQuery('''
      SELECT 
        currency,
        SUM(CASE WHEN isForMe = 1 THEN amount ELSE 0 END) as forMe,
        SUM(CASE WHEN isForMe = 0 THEN amount ELSE 0 END) as onMe
      FROM transactions
      GROUP BY currency
      ORDER BY currency
    ''');

    return result
        .map(
          (row) => CurrencyBreakdown(
            currency: row['currency'] as String,
            forMe: (row['forMe'] as num?)?.toDouble() ?? 0,
            onMe: (row['onMe'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList();
  }
}
