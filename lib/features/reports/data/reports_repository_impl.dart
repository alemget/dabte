import 'package:dabdt/data/debt_database.dart';

import 'package:dabdt/features/reports/domain/entities/client_net_summary.dart';
import 'package:dabdt/features/reports/domain/entities/currency_summary.dart';
import 'package:dabdt/features/reports/domain/entities/reports_overview.dart';
import 'package:dabdt/features/reports/domain/repositories/reports_repository.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final DebtDatabase _db;

  ReportsRepositoryImpl({DebtDatabase? db}) : _db = db ?? DebtDatabase.instance;

  @override
  Future<ReportsOverview> getOverview({int topClientsLimit = 8}) async {
    final summaries = await _db.getAllClientsSummaries();
    final currencyRows = await _db.getCurrencyTotals();

    final currencies = <CurrencySummary>[];
    DateTime? lastTransactionDate;

    for (final row in currencyRows) {
      final currency = row['currency'] as String?;
      if (currency == null || currency.trim().isEmpty) continue;

      final forMe = (row['forMe'] as num?)?.toDouble() ?? 0;
      final onMe = (row['onMe'] as num?)?.toDouble() ?? 0;
      currencies.add(CurrencySummary(currency: currency, forMe: forMe, onMe: onMe));

      final lastDateStr = row['lastTransactionDate'] as String?;
      final dt = lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;
      if (dt != null) {
        final currentLast = lastTransactionDate;
        if (currentLast == null || dt.isAfter(currentLast)) {
          lastTransactionDate = dt;
        }
      }
    }

    final clients = <ClientNetSummary>[];

    for (final entry in summaries.entries) {
      final data = entry.value;
      final netByCurrency = Map<String, double>.from(
        (data['netByCurrency'] as Map?) ?? <String, double>{},
      );

      DateTime? clientLast;
      final lastStr = data['lastTransactionDate'] as String?;
      if (lastStr != null) {
        clientLast = DateTime.tryParse(lastStr);
      }

      if (clientLast != null) {
        final currentLast = lastTransactionDate;
        if (currentLast == null || clientLast.isAfter(currentLast)) {
          lastTransactionDate = clientLast;
        }
      }

      clients.add(
        ClientNetSummary(
          id: data['id'] as int,
          name: data['name'] as String,
          phone: data['phone'] as String?,
          netByCurrency: netByCurrency,
          lastTransactionDate: clientLast,
        ),
      );
    }

    clients.sort((a, b) {
      final aScore = (a.primaryNet ?? 0).abs();
      final bScore = (b.primaryNet ?? 0).abs();
      return bScore.compareTo(aScore);
    });

    final topClients = clients.take(topClientsLimit).toList();

    currencies.sort((a, b) => b.net.abs().compareTo(a.net.abs()));

    return ReportsOverview(
      clientsCount: summaries.length,
      currenciesCount: currencies.length,
      lastTransactionDate: lastTransactionDate,
      currencies: currencies,
      topClients: topClients,
    );
  }
}
