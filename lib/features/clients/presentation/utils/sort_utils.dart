import '../../domain/entities/client.dart';
import '../state/client_provider.dart';

enum SortOption { name, dateAdded, lastTransaction }

enum SortOrder { ascending, descending }

class SortUtils {
  static List<Client> applySorting({
    required List<Client> clients,
    required Map<int, ClientSummary> summaries,
    required SortOption sortOption,
    required SortOrder sortOrder,
  }) {
    final sorted = List<Client>.from(clients);

    sorted.sort((a, b) {
      int comparison;

      switch (sortOption) {
        case SortOption.name:
          comparison = a.name.compareTo(b.name);
          break;

        case SortOption.dateAdded:
          final aDate = a.createdAt ?? DateTime(2000);
          final bDate = b.createdAt ?? DateTime(2000);
          comparison = aDate.compareTo(bDate);
          break;

        case SortOption.lastTransaction:
          final aLast = a.id != null ? summaries[a.id!]?.lastTransactionDate : null;
          final bLast = b.id != null ? summaries[b.id!]?.lastTransactionDate : null;

          if (aLast == null && bLast == null) {
            comparison = 0;
          } else if (aLast == null) {
            comparison = 1;
          } else if (bLast == null) {
            comparison = -1;
          } else {
            comparison = aLast.compareTo(bLast);
          }
          break;
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return sorted;
  }
}
