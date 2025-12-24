import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import 'client_details_page.dart';
import 'add_edit_client_page.dart';

// Import extracted components
import 'utils/sort_utils.dart';
import 'widgets/client_card.dart';
import 'widgets/client_search_bar.dart';
import 'widgets/sort_option_tile.dart';
import 'widgets/order_button.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = '';
  SortOption _sortOption = SortOption.name;
  SortOrder _sortOrder = SortOrder.ascending;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _filter = _searchController.text.toLowerCase());
    });
    _loadSortPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
    });
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final sortOptionString = prefs.getString('sort_option');
    if (sortOptionString != null) {
      _sortOption = SortOption.values.firstWhere(
        (e) => e.name == sortOptionString,
        orElse: () => SortOption.name,
      );
    }
    final sortOrderString = prefs.getString('sort_order');
    if (sortOrderString != null) {
      _sortOrder = sortOrderString == 'ascending'
          ? SortOrder.ascending
          : SortOrder.descending;
    }
    setState(() {});
  }

  Future<void> _saveSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sort_option', _sortOption.name);
    await prefs.setString(
      'sort_order',
      _sortOrder == SortOrder.ascending ? 'ascending' : 'descending',
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddClientDialog() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditClientPage()),
    );
    if (result == true && mounted) {
      context.read<ClientProvider>().loadClients(forceRefresh: true);
    }
  }

  Future<void> _showEditClientDialog(Client client) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditClientPage(client: client),
      ),
    );
    if (result == true && mounted) {
      context.read<ClientProvider>().loadClients(forceRefresh: true);
    }
  }

  Future<void> _deleteClient(Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmDialog(clientName: client.name),
    );
    if (confirm == true && client.id != null && mounted) {
      await context.read<ClientProvider>().deleteClient(client.id!);
    }
  }

  void _showClientOptions(Client client) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClientOptionsSheet(
        client: client,
        onEdit: () {
          Navigator.pop(context);
          _showEditClientDialog(client);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteClient(client);
        },
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  String _getSortLabel() {
    String label;
    switch (_sortOption) {
      case SortOption.name:
        label = AppLocalizations.of(context)!.clientName;
        break;
      case SortOption.dateAdded:
        label = 'تاريخ الإضافة';
        break;
      case SortOption.lastTransaction:
        label = 'آخر معاملة';
        break;
    }
    return label;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SortOptionsSheet(
        currentOption: _sortOption,
        currentOrder: _sortOrder,
        onOptionChanged: (option) {
          setState(() => _sortOption = option);
          _saveSortPreferences();
        },
        onOrderChanged: (order) {
          setState(() => _sortOrder = order);
          _saveSortPreferences();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClientProvider>(
      builder: (context, provider, child) {
        final clients = provider.clients;
        final summaries = provider.summaries;
        final loading = provider.loading;

        final filtered = clients
            .where((c) => c.name.toLowerCase().contains(_filter))
            .toList();
        final sorted = SortUtils.applySorting(
          clients: filtered,
          summaries: summaries,
          sortOption: _sortOption,
          sortOrder: _sortOrder,
        );
        final isRTL = AppLocalizations.of(context)!.localeName.startsWith('ar');

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: 56,
                  title: Text(
                    AppLocalizations.of(context)!.clients,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D1E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  centerTitle: true,
                  actions: [
                    _SortButton(
                      label: _getSortLabel(),
                      isAscending: _sortOrder == SortOrder.ascending,
                      onTap: _showSortOptions,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: ClientSearchBar(controller: _searchController),
                  ),
                ),

                // Stats Bar
                SliverToBoxAdapter(
                  child: _StatsBar(
                    totalClients: sorted.length,
                    clientsWithDebt: sorted.where((c) {
                      final s = c.id != null ? summaries[c.id!] : null;
                      return s != null && s.netByCurrency.isNotEmpty;
                    }).length,
                  ),
                ),

                // Client List
                if (loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (sorted.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(hasFilter: _filter.isNotEmpty),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final client = sorted[index];
                        final summary = client.id != null
                            ? summaries[client.id!]
                            : null;
                        return ClientCard(
                          key: ValueKey(client.id),
                          client: client,
                          summary: summary,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ClientDetailsPage(client: client),
                              ),
                            );
                            context.read<ClientProvider>().loadClients(
                              forceRefresh: true,
                            );
                          },
                          onLongPress: () => _showClientOptions(client),
                          onCallPressed:
                              client.phone != null && client.phone!.isNotEmpty
                              ? () => _makePhoneCall(client.phone!)
                              : null,
                        );
                      }, childCount: sorted.length),
                    ),
                  ),
              ],
            ),
            floatingActionButton: _AddClientFAB(
              onPressed: _showAddClientDialog,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOCAL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _SortButton extends StatelessWidget {
  final String label;
  final bool isAscending;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.isAscending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final int totalClients;
  final int clientsWithDebt;

  const _StatsBar({required this.totalClients, required this.clientsWithDebt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.people_outline,
            label: '$totalClients عميل',
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.account_balance_wallet_outlined,
            label: '$clientsWithDebt لديهم ديون',
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                hasFilter ? Icons.search_off : Icons.people_outline,
                size: 28,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? AppLocalizations.of(context)!.noClientsDescription
                  : AppLocalizations.of(context)!.noClients,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddClientFAB extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddClientFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      elevation: 2,
      backgroundColor: const Color(0xFF3B82F6),
      child: const Icon(Icons.add, size: 24),
    );
  }
}

class _SortOptionsSheet extends StatelessWidget {
  final SortOption currentOption;
  final SortOrder currentOrder;
  final ValueChanged<SortOption> onOptionChanged;
  final ValueChanged<SortOrder> onOrderChanged;

  const _SortOptionsSheet({
    required this.currentOption,
    required this.currentOrder,
    required this.onOptionChanged,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                AppLocalizations.of(context)!.sortBy,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D1E),
                ),
              ),
              const SizedBox(height: 12),

              // Options
              SortOptionTile(
                title: AppLocalizations.of(context)!.clientName,
                icon: Icons.sort_by_alpha,
                isSelected: currentOption == SortOption.name,
                onTap: () => onOptionChanged(SortOption.name),
              ),
              SortOptionTile(
                title: 'تاريخ الإضافة',
                icon: Icons.calendar_today_outlined,
                isSelected: currentOption == SortOption.dateAdded,
                onTap: () => onOptionChanged(SortOption.dateAdded),
              ),
              SortOptionTile(
                title: 'آخر معاملة',
                icon: Icons.access_time,
                isSelected: currentOption == SortOption.lastTransaction,
                onTap: () => onOptionChanged(SortOption.lastTransaction),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Order Toggle
              Row(
                children: [
                  Expanded(
                    child: OrderButton(
                      title: 'تصاعدي',
                      icon: Icons.arrow_upward,
                      isSelected: currentOrder == SortOrder.ascending,
                      onTap: () => onOrderChanged(SortOrder.ascending),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OrderButton(
                      title: 'تنازلي',
                      icon: Icons.arrow_downward,
                      isSelected: currentOrder == SortOrder.descending,
                      onTap: () => onOrderChanged(SortOrder.descending),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientOptionsSheet extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientOptionsSheet({
    required this.client,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                client.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _SheetOption(
                icon: Icons.edit_outlined,
                title: AppLocalizations.of(context)!.editClient,
                color: const Color(0xFF3B82F6),
                onTap: onEdit,
              ),
              _SheetOption(
                icon: Icons.delete_outline,
                title: AppLocalizations.of(context)!.deleteClient,
                color: const Color(0xFFEF4444),
                onTap: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final String clientName;
  const _DeleteConfirmDialog({required this.clientName});

  @override
  Widget build(BuildContext context) {
    final isRTL = AppLocalizations.of(context)!.localeName.startsWith('ar');
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.confirmDelete,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.confirmDeleteClient,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }
}
