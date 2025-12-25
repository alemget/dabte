import 'package:flutter/foundation.dart';

import 'package:dabdt/features/reports/data/reports_repository_impl.dart';
import 'package:dabdt/features/reports/domain/entities/reports_overview.dart';
import 'package:dabdt/features/reports/domain/repositories/reports_repository.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsRepository _repository;

  ReportsOverview? _overview;
  bool _loading = false;
  String? _error;

  ReportsProvider({ReportsRepository? repository})
      : _repository = repository ?? ReportsRepositoryImpl();

  ReportsOverview? get overview => _overview;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _overview = await _repository.getOverview();
      _loading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = e.toString();
      _loading = false;
      debugPrint('Error loading reports: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }
}
