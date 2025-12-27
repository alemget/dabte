import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/currency_data.dart';
import '../../intro_provider.dart';
import '../../theme/intro_theme.dart';

/// Currency setup page - Third/Last page in the onboarding flow
/// Allows user to select their primary currency
class CurrencyPage extends StatefulWidget {
  const CurrencyPage({super.key});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
  // Popular currencies to display
  final List<String> _codes = [
    'SAR',
    'USD',
    'EUR',
    'AED',
    'EGP',
    'KWD',
    'QAR',
    'GBP',
    'TRY',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IntroProvider>();
    final currencies = provider.availableCurrencies
        .where((c) => _codes.contains(c.code))
        .toList();
    final selected = provider.primaryCurrency != null;

    return Padding(
      padding: const EdgeInsets.all(IntroTheme.padding),
      child: Column(
        children: [
          // ─────────────────────────────────────────────────────────
          // Question Card (Placeholder - سيتم تصميمها لاحقاً)
          // ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: selected
                ? IntroTheme.activeCardDecoration
                : IntroTheme.cardDecoration,
            child: Column(
              children: [
                Icon(
                  Icons.currency_exchange,
                  size: 40,
                  color: selected
                      ? IntroTheme.primary
                      : IntroTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                const Text('اختر عملتك', style: IntroTheme.pageTitle),
                if (selected) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: IntroTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.primaryCurrency!.code,
                        style: const TextStyle(
                          color: IntroTheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─────────────────────────────────────────────────────────
          // Currency Grid
          // ─────────────────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected =
                    provider.primaryCurrency?.code == currency.code;
                final flag = CurrencyData.all
                    .firstWhere(
                      (e) => e.code == currency.code,
                      orElse: () => CurrencyOption(
                        name: '',
                        code: currency.code,
                        flag: '🏳️',
                      ),
                    )
                    .flag;

                return GestureDetector(
                  onTap: () {
                    provider.selectPrimaryCurrency(currency);
                    provider.setCurrencyReady(true);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? IntroTheme.primary.withOpacity(0.1)
                          : IntroTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? IntroTheme.primary
                            : IntroTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          currency.code,
                          style: TextStyle(
                            color: isSelected
                                ? IntroTheme.primary
                                : IntroTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ─────────────────────────────────────────────────────────
          // Start Button
          // ─────────────────────────────────────────────────────────
          if (selected)
            GestureDetector(
              onTap: () => provider.completeIntro(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: IntroTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ابدأ الآن',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            )
          else
            Text(
              'اختر عملة للمتابعة',
              style: TextStyle(color: IntroTheme.textHint, fontSize: 14),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
