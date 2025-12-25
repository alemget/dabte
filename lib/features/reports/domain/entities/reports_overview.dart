import 'client_net_summary.dart';
import 'currency_summary.dart';

class ReportsOverview {
  final int clientsCount;
  final int currenciesCount;
  final DateTime? lastTransactionDate;
  final List<CurrencySummary> currencies;
  final List<ClientNetSummary> topClients;

  const ReportsOverview({
    required this.clientsCount,
    required this.currenciesCount,
    required this.lastTransactionDate,
    required this.currencies,
    required this.topClients,
  });
}
