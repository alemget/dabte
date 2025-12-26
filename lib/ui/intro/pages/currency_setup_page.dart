import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../data/currency_data.dart';
import '../intro_provider.dart';

class CurrencySetupPage extends StatelessWidget {
  const CurrencySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IntroProvider>();
    final currencies = provider.availableCurrencies;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Header with AI-like copy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.monetization_on_outlined,
                    size: 40,
                    color: Color(0xFF5C6EF8),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                        'لنبدأ بأساسيات معاملاتك المالية..',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .moveY(begin: 10, end: 0, duration: 600.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'تخصيص العملة هو الخطوة الأولى لضبط حساباتك بدقة. ما هي عملتك الأساسية؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Selection Status (Conversational)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _CurrencyRow(
                    label: 'عملتي الأساسية هي:',
                    code: provider.primaryCurrency?.code,
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber,
                    onTap: () {}, // Trigger focus or help
                  ),
                  if (provider.secondaryCurrency != null) ...[
                    const Divider(height: 24).animate().fadeIn(),
                    _CurrencyRow(
                      label: 'وأستخدم أيضاً:',
                      code: provider.secondaryCurrency?.code,
                      icon: Icons.swap_horiz_rounded,
                      iconColor: Colors.blue,
                      onClear: () => provider.toggleSecondaryCurrency(
                        provider.secondaryCurrency!,
                      ),
                    ).animate().fadeIn().slideX(begin: 0.1, end: 0),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),

            const SizedBox(height: 24),

            // Search / Filter place holder (Visual only for now)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن عملة (مثال: دولار، يورو..)',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 16),

            // Modern Grid/List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: currencies.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final option = CurrencyData.all.firstWhere(
                    (e) => e.code == currency.code,
                    orElse: () => CurrencyOption(
                      name: currency.name,
                      code: currency.code,
                      flag: '🏳️',
                    ),
                  );

                  final isPrimary =
                      provider.primaryCurrency?.code == currency.code;
                  final isSecondary =
                      provider.secondaryCurrency?.code == currency.code;
                  final isSelected = isPrimary || isSecondary;

                  return AnimatedContainer(
                        duration: 300.ms,
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isPrimary
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(
                                        0xFFEFF6FF,
                                      )) // Green-Ish or Blue-ish
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPrimary
                                ? Colors.green.withOpacity(0.5)
                                : isSecondary
                                ? Colors.blue.withOpacity(0.5)
                                : Colors.transparent,
                            width: isSelected ? 2 : 0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: (isPrimary ? Colors.green : Colors.blue)
                                    .withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (provider.primaryCurrency == null) {
                                provider.selectPrimaryCurrency(currency);
                              } else if (isPrimary) {
                                // feedback?
                              } else {
                                provider.toggleSecondaryCurrency(currency);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      option.flag,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? Colors.black87
                                                : Colors.black54,
                                          ),
                                        ),
                                        Text(
                                          option.code,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade400,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: isPrimary
                                          ? Colors.green
                                          : Colors.blue,
                                    ).animate().scale(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate(delay: (50 * index).ms)
                      .fadeIn()
                      .slideX(begin: 0.1, end: 0);
                },
              ),
            ),

            // Floating Action Button Style Next
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton(
                          onPressed: provider.primaryCurrency != null
                              ? () => provider.nextPage()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C6EF8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: provider.primaryCurrency != null ? 8 : 0,
                            shadowColor: const Color(
                              0xFF5C6EF8,
                            ).withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'ممتاز، التالي',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        )
                        .animate(
                          target: provider.primaryCurrency != null ? 1 : 0,
                        )
                        .scaleXY(end: 1, curve: Curves.easeOutBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  final String label;
  final String? code;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _CurrencyRow({
    required this.label,
    this.code,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (code != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    code!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (onClear != null) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onClear,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().scale(curve: Curves.elasticOut, duration: 400.ms)
          else
            const Text('---', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
