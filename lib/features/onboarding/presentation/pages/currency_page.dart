import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/currency_data.dart';
import '../../shared/theme/onboarding_theme.dart';
import '../setup/onboarding_provider.dart';

class CurrencyPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const CurrencyPage({super.key, required this.onCompleted});

  @override
  State<CurrencyPage> createState() => _CurrencyPageState();
}

class _CurrencyPageState extends State<CurrencyPage> {
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
    final provider = context.watch<OnboardingProvider>();
    final currencies = provider.availableCurrencies
        .where((c) => _codes.contains(c.code))
        .toList();
    final selected = provider.primaryCurrency != null;

    return Padding(
      padding: const EdgeInsets.all(OnboardingTheme.padding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: selected
                ? OnboardingTheme.activeCardDecoration
                : OnboardingTheme.cardDecoration,
            child: Column(
              children: [
                Icon(
                  Icons.currency_exchange,
                  size: 40,
                  color: selected
                      ? OnboardingTheme.primary
                      : OnboardingTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                const Text('اختر عملتك', style: OnboardingTheme.pageTitle),
                if (selected) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: OnboardingTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.primaryCurrency!.code,
                        style: const TextStyle(
                          color: OnboardingTheme.primary,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                final isSelected = provider.primaryCurrency?.code == currency.code;
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
                          ? OnboardingTheme.primary.withOpacity(0.12)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? OnboardingTheme.primary
                            : OnboardingTheme.border,
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
                                ? OnboardingTheme.primary
                                : OnboardingTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
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
          if (selected)
            GestureDetector(
              onTap: () => provider.complete().then((_) => widget.onCompleted()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: OnboardingTheme.primary,
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
              style: TextStyle(
                color: OnboardingTheme.textSecondary.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
