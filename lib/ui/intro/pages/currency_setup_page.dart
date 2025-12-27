import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/currency_data.dart';
import '../intro_provider.dart';

class CurrencySetupPage extends StatefulWidget {
  const CurrencySetupPage({super.key});

  @override
  State<CurrencySetupPage> createState() => _CurrencySetupPageState();
}

class _CurrencySetupPageState extends State<CurrencySetupPage> {
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              const Text(
                'ديوني',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4ECDC4),
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 8),

              // Progress - all filled
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 2 ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Question
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF4ECDC4).withOpacity(0.5)
                        : Colors.white12,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.currency_exchange,
                      size: 36,
                      color: selected
                          ? const Color(0xFF4ECDC4)
                          : Colors.white54,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'اختر عملتك',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4ECDC4),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            provider.primaryCurrency!.code,
                            style: const TextStyle(
                              color: Color(0xFF4ECDC4),
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

              // Currency Grid
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
                              ? const Color(0xFF4ECDC4).withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4ECDC4)
                                : Colors.white12,
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
                                    ? const Color(0xFF4ECDC4)
                                    : Colors.white70,
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

              // Action
              if (selected)
                GestureDetector(
                  onTap: () => provider.completeIntro(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ECDC4),
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
                            color: Color(0xFF1a1a2e),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Color(0xFF1a1a2e)),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  'اختر عملة للمتابعة',
                  style: TextStyle(color: Colors.white30, fontSize: 14),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
