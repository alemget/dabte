import 'package:flutter/foundation.dart';
import '../data/repositories/client_repository.dart';
import '../models/client.dart';

/// Data class for client summary
class ClientSummary {
  final Map<String, double> netByCurrency;
  final DateTime? lastTransactionDate;

  ClientSummary({
    required this.netByCurrency,
    this.lastTransactionDate,
  });
}

/// Provider for managing client state
/// Handles loading, adding, updating, and deleting clients
class ClientProvider extends ChangeNotifier {
  final ClientRepository _repository = ClientRepository();
  
  List<Client> _clients = [];
  Map<int, ClientSummary> _summaries = {};
  bool _loading = false;
  String? _error;
  
  // Getters
  List<Client> get clients => _clients;
  Map<int, ClientSummary> get summaries => _summaries;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasClients => _clients.isNotEmpty;
  
  /// Load all clients with their summaries
  Future<void> loadClients({bool forceRefresh = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final summariesData = await _repository.getClientsSummaries(
        forceRefresh: forceRefresh,
      );
      
      // Convert to Client and ClientSummary objects
      final List<Client> clients = [];
      final Map<int, ClientSummary> summaries = {};
      
      for (final entry in summariesData.entries) {
        final clientId = entry.key;
        final data = entry.value;
        
        // Create Client object
        clients.add(Client(
          id: data['id'] as int,
          name: data['name'] as String,
          phone: data['phone'] as String?,
          createdAt: data['createdAt'] != null 
              ? DateTime.parse(data['createdAt'] as String)
              : null,
        ));
        
        // Create ClientSummary object
        summaries[clientId] = ClientSummary(
          netByCurrency: Map<String, double>.from(data['netByCurrency'] as Map),
          lastTransactionDate: data['lastTransactionDate'] != null
              ? DateTime.parse(data['lastTransactionDate'] as String)
              : null,
        );
      }
      
      _clients = clients;
      _summaries = summaries;
      _loading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = e.toString();
      _loading = false;
      debugPrint('Error loading clients: $e');
      debugPrint('Stack trace: $stackTrace');
      notifyListeners();
    }
  }
  
  /// Add a new client
  Future<bool> addClient(String name, {String? phone}) async {
    try {
      await _repository.addClient(name, phone: phone);
      await loadClients(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding client: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Update an existing client
  Future<bool> updateClient(int id, String name, {String? phone}) async {
    try {
      await _repository.updateClient(id, name, phone: phone);
      await loadClients(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating client: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Delete a client
  Future<bool> deleteClient(int id) async {
    try {
      await _repository.deleteClient(id);
      await loadClients(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting client: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Refresh clients (force reload from database)
  Future<void> refresh() async {
    await loadClients(forceRefresh: true);
  }
}
