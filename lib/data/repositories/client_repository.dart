import '../debt_database.dart';
import '../../services/notification_service.dart';

/// Repository for client data operations
/// Provides a clean API and caching layer between UI and database
class ClientRepository {
  final DebtDatabase _db = DebtDatabase.instance;
  
  // Cache for summaries
  Map<int, Map<String, dynamic>>? _summariesCache;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);
  
  /// Get all clients with their summaries
  /// Uses cache if available and not expired
  Future<Map<int, Map<String, dynamic>>> getClientsSummaries({
    bool forceRefresh = false,
  }) async {
    // Check cache validity
    if (!forceRefresh && _summariesCache != null && _cacheTime != null) {
      final cacheAge = DateTime.now().difference(_cacheTime!);
      if (cacheAge < _cacheDuration) {
        return _summariesCache!;
      }
    }
    
    // Fetch from database
    final summaries = await _db.getAllClientsSummaries();
    
    // Update cache
    _summariesCache = summaries;
    _cacheTime = DateTime.now();
    
    return summaries;
  }
  
  /// Add a new client
  Future<int> addClient(String name, {String? phone}) async {
    final id = await _db.insertClient(name, phone: phone);
    clearCache();
    return id;
  }
  
  /// Update an existing client
  Future<void> updateClient(int id, String name, {String? phone}) async {
    await _db.updateClient(id, name, phone: phone);
    clearCache();
  }
  
  /// Delete a client and all their transactions
  Future<void> deleteClient(int id) async {
    final txs = await _db.getClientTransactions(id);
    await NotificationService.instance.initialize();
    for (final tx in txs) {
      if (tx.id != null) {
        await NotificationService.instance.cancelReminder(tx.id!);
      }
    }

    await _db.deleteClient(id);
    clearCache();
  }
  
  /// Clear the cache (call after any data modification)
  void clearCache() {
    _summariesCache = null;
    _cacheTime = null;
  }
  
  /// Check if cache is valid
  bool get isCacheValid {
    if (_summariesCache == null || _cacheTime == null) return false;
    final cacheAge = DateTime.now().difference(_cacheTime!);
    return cacheAge < _cacheDuration;
  }
}
