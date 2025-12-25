import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'models/models.dart';
import 'services/services.dart';
import 'widgets/widgets.dart';

/// صفحة التقارير الرئيسية
/// Main reports page
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsService _reportsService = ReportsService();

  // حالة التحميل
  bool _isLoading = true;
  String? _error;

  // البيانات
  ReportSummary _summary = ReportSummary.empty();
  List<ClientDebtInfo> _topDebtors = [];
  TransactionStats _transactionStats = TransactionStats.empty();
  List<CurrencyBreakdown> _currencyBreakdown = [];

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  /// تحميل جميع بيانات التقارير
  Future<void> _loadReportsData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // تحميل البيانات بالتوازي
      final results = await Future.wait([
        _reportsService.getReportSummary(),
        _reportsService.getTopDebtors(limit: 5),
        _reportsService.getTransactionStats(),
        _reportsService.getCurrencyBreakdown(),
      ]);

      setState(() {
        _summary = results[0] as ReportSummary;
        _topDebtors = results[1] as List<ClientDebtInfo>;
        _transactionStats = results[2] as TransactionStats;
        _currencyBreakdown = results[3] as List<CurrencyBreakdown>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = l10n.localeName.startsWith('ar');

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
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
                l10n.reports,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1D1E),
                  letterSpacing: -0.3,
                ),
              ),
              centerTitle: true,
              actions: [
                // زر التحديث
                IconButton(
                  onPressed: _loadReportsData,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF64748B),
                  ),
                  tooltip: 'تحديث',
                ),
                const SizedBox(width: 4),
              ],
            ),

            // المحتوى
            if (_isLoading)
              const SliverFillRemaining(child: _LoadingState())
            else if (_error != null)
              SliverFillRemaining(
                child: _ErrorState(error: _error!, onRetry: _loadReportsData),
              )
            else if (_summary.totalClients == 0)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),

                  // 1. بطاقة الملخص الرئيسي
                  SummaryCard(summary: _summary),

                  // 2. بطاقة العملاء
                  ClientsOverviewCard(
                    totalClients: _summary.totalClients,
                    clientsWithDebts: _summary.clientsWithDebts,
                    topDebtors: _topDebtors,
                  ),

                  // 3. بطاقة المعاملات
                  TransactionsReportCard(stats: _transactionStats),

                  // 4. بطاقة العملات
                  CurrencyReportCard(currencies: _currencyBreakdown),

                  // تباعد في الأسفل
                  const SizedBox(height: 100),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

/// حالة التحميل
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل التقارير...',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// حالة الخطأ
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

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
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFEF4444),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// حالة فارغة
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                color: Color(0xFF3B82F6),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد بيانات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة عملاء ومعاملات\nلتظهر هنا التقارير والإحصائيات',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
