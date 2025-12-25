import '../entities/reports_overview.dart';

abstract class ReportsRepository {
  Future<ReportsOverview> getOverview({int topClientsLimit = 8});
}
