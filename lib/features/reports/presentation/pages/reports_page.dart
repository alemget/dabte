import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dabdt/features/reports/domain/entities/client_net_summary.dart';
import 'package:dabdt/features/reports/domain/entities/currency_summary.dart';
import 'package:dabdt/features/reports/presentation/providers/reports_provider.dart';
import 'package:dabdt/l10n/app_localizations.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportsProvider()..load(),
      child: const _ReportsPageBody(),
    );
  }
}

class _ReportsPageBody extends StatelessWidget {
  const _ReportsPageBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.reports),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<ReportsProvider>().load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (provider.error != null) {
            return _ErrorState(
              message: provider.error!,
              onRetry: () => provider.load(),
            );
          }

          final overview = provider.overview;
          if (overview == null || overview.clientsCount == 0) {
            return _EmptyState(onRefresh: () => provider.load());
          }

          return RefreshIndicator(
            onRefresh: () => provider.load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _SectionTitle(title: l10n.reportsOverview),
                const SizedBox(height: 10),
                _KpisRow(
                  clientsCount: overview.clientsCount,
                  currenciesCount: overview.currenciesCount,
                  lastTransactionDate: overview.lastTransactionDate,
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: l10n.reportsByCurrency),
                const SizedBox(height: 10),
                _CurrencySummaryCard(currencies: overview.currencies),
                const SizedBox(height: 16),
                _SectionTitle(title: l10n.reportsTopClients),
                const SizedBox(height: 10),
                _TopClientsCard(clients: overview.topClients),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _KpisRow extends StatelessWidget {
  final int clientsCount;
  final int currenciesCount;
  final DateTime? lastTransactionDate;

  const _KpisRow({
    required this.clientsCount,
    required this.currenciesCount,
    required this.lastTransactionDate,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.people_outline,
            title: l10n.clients,
            value: clientsCount.toString(),
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.currency_exchange,
            title: l10n.reportsCurrencies,
            value: currenciesCount.toString(),
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _KpiCard(
            icon: Icons.access_time,
            title: l10n.reportsLastActivity,
            value: _formatDate(lastTransactionDate),
            color: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySummaryCard extends StatelessWidget {
  final List<CurrencySummary> currencies;

  const _CurrencySummaryCard({required this.currencies});

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.bar_chart, size: 16, color: Color(0xFF111827)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reportsByCurrency,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final c in currencies)
            _CurrencyRow(
              currency: c.currency,
              forMe: _fmt(c.forMe),
              onMe: _fmt(c.onMe),
              net: _fmt(c.net),
              isNetPositive: c.net >= 0,
            ),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final String currency;
  final String forMe;
  final String onMe;
  final String net;
  final bool isNetPositive;

  const _CurrencyRow({
    required this.currency,
    required this.forMe,
    required this.onMe,
    required this.net,
    required this.isNetPositive,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              currency,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.forMe}: $forMe',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF059669)),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${l10n.onMe}: $onMe',
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.net}: $net',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isNetPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopClientsCard extends StatelessWidget {
  final List<ClientNetSummary> clients;

  const _TopClientsCard({required this.clients});

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.star_outline, size: 16, color: Color(0xFF111827)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reportsTopClients,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final c in clients) _TopClientRow(client: c, fmt: _fmt),
        ],
      ),
    );
  }
}

class _TopClientRow extends StatelessWidget {
  final ClientNetSummary client;
  final String Function(double) fmt;

  const _TopClientRow({required this.client, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final primaryCurrency = client.primaryCurrency;
    final primaryNet = client.primaryNet;

    final isPositive = (primaryNet ?? 0) >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    if (client.phone != null && client.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        client.phone!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ],
                ),
              ),
              if (primaryCurrency != null && primaryNet != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${fmt(primaryNet)} $primaryCurrency',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          if (client.netByCurrency.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: client.netByCurrency.entries.map((e) {
                final v = e.value;
                final positive = v >= 0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (positive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: (positive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withAlpha(60),
                    ),
                  ),
                  child: Text(
                    '${e.key}: ${fmt(v)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: positive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                Icons.bar_chart_outlined,
                size: 28,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reportsNoData,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.noClientsDescription,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.error,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
