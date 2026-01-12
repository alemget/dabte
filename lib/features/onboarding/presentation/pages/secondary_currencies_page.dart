import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/currency_data.dart';
import '../../shared/theme/onboarding_theme.dart';
import '../setup/onboarding_provider.dart';

class SecondaryCurrenciesPage extends StatefulWidget {
  final VoidCallback onCompleted;

  const SecondaryCurrenciesPage({super.key, required this.onCompleted});

  @override
  State<SecondaryCurrenciesPage> createState() =>
      _SecondaryCurrenciesPageState();
}

class _SecondaryCurrenciesPageState extends State<SecondaryCurrenciesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final allCurrencies = provider.availableCurrencies;
    final primaryCode = provider.primaryCurrency?.code;
    final selectedCodes = provider.secondaryCurrencies
        .map((c) => c.code)
        .toSet();

    // تصفية العملات: إزالة العملة الرئيسية
    final availableCurrencies = allCurrencies
        .where((c) => c.code != primaryCode)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // البطاقة الرئيسية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selectedCodes.isNotEmpty
                        ? OnboardingTheme.primary.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // أيقونة العملات
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: selectedCodes.isNotEmpty
                            ? OnboardingTheme.primary.withOpacity(0.15)
                            : Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedCodes.isNotEmpty
                              ? OnboardingTheme.primary.withOpacity(0.5)
                              : Colors.white.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 28,
                        color: selectedCodes.isNotEmpty
                            ? OnboardingTheme.primary
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'إضافة عملات فرعية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختر العملات التي تتعامل بها (اختياري)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    if (selectedCodes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: provider.secondaryCurrencies.map((currency) {
                          final flag = CurrencyData.all
                              .firstWhere(
                                (e) => e.code == currency.code,
                                orElse: () => const CurrencyOption(
                                  name: '',
                                  code: '',
                                  flag: '🏳️',
                                ),
                              )
                              .flag;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: OnboardingTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: OnboardingTheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  flag,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  currency.code,
                                  style: const TextStyle(
                                    color: OnboardingTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      // رسالة توجيهية أنيقة
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF667EEA).withOpacity(0.12),
                              const Color(0xFF764BA2).withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF667EEA).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'يمكن إضافة عملات أخرى من الإعدادات لاحقاً',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // شبكة العملات
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: availableCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = availableCurrencies[index];
                    final isSelected = selectedCodes.contains(currency.code);
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

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (isSelected) {
                            provider.removeSecondaryCurrency(currency.code);
                          } else {
                            provider.addSecondaryCurrency(currency);
                          }
                        },
                        borderRadius: BorderRadius.circular(24),
                        splashColor: OnboardingTheme.primary.withOpacity(0.2),
                        highlightColor: OnboardingTheme.primary.withOpacity(
                          0.1,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      OnboardingTheme.primary.withOpacity(0.2),
                                      OnboardingTheme.primary.withOpacity(0.08),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.03),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? OnboardingTheme.primary.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.1),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: OnboardingTheme.primary
                                          .withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.1 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Text(
                                        flag,
                                        style: const TextStyle(fontSize: 34),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currency.code,
                                      style: TextStyle(
                                        color: isSelected
                                            ? OnboardingTheme.primary
                                            : Colors.white.withOpacity(0.75),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Cairo',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // علامة الاختيار المتحركة
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutBack,
                                top: isSelected ? 8 : -20,
                                right: 8,
                                child: AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          OnboardingTheme.primary,
                                          Color(0xFF3DB8B0),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: OnboardingTheme.primary
                                              .withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // زر المتابعة
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onCompleted,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [OnboardingTheme.primary, Color(0xFF3DB8B0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: OnboardingTheme.primary.withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedCodes.isEmpty ? 'تخطي' : 'ابدأ الآن',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
