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

class _CurrencyPageState extends State<CurrencyPage>
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

  void _goBack() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onContinue() {
    // إظهار مربع حوار للسؤال عن العملات الفرعية
    _showSecondaryCurrenciesDialog();
  }

  void _showSecondaryCurrenciesDialog() {
    // نحصل على Provider هنا باستخدام context الصفحة الذي يحتوي على Provider
    // لأن context الحوار قد يكون في مكان مختلف في شجرة الويجت
    final provider = Provider.of<OnboardingProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: OnboardingTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: OnboardingTheme.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  color: OnboardingTheme.primary,
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              // العنوان
              const Text(
                'إضافة عملات فرعية؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 12),

              // الوصف
              Text(
                'هل تريد إضافة عملات أخرى للتعامل بها؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Cairo',
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // الأزرار
              Row(
                children: [
                  // زر لا
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogContext);
                        // الانتقال مباشرة لصفحة النسخ الاحتياطي (صفحة 3) بدلاً من العملات الفرعية
                        provider.pageController.animateToPage(
                          3,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Text(
                          'لا، شكراً',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // زر نعم
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(dialogContext);
                        // الانتقال لشاشة العملات الفرعية باستخدام Provider المجتلب مسبقاً
                        provider.pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              OnboardingTheme.primary,
                              Color(0xFF3DB8B0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: OnboardingTheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'نعم، إضافة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();
    final currencies = provider.availableCurrencies;
    final selected = provider.primaryCurrency != null;

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
                    color: selected
                        ? OnboardingTheme.primary.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // أيقونة العملة
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: selected
                            ? OnboardingTheme.primary.withOpacity(0.15)
                            : Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? OnboardingTheme.primary.withOpacity(0.5)
                              : Colors.white.withOpacity(0.15),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.currency_exchange_rounded,
                        size: 28,
                        color: selected
                            ? OnboardingTheme.primary
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'اختر عملتك الرئيسية',
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
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: OnboardingTheme.primary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: OnboardingTheme.primary,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            provider.primaryCurrency!.code,
                            style: const TextStyle(
                              color: OnboardingTheme.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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

              // شبكة العملات
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
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
                              ? OnboardingTheme.primary.withOpacity(0.15)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? OnboardingTheme.primary
                                : Colors.white.withOpacity(0.12),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: OnboardingTheme.primary.withOpacity(
                                      0.2,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(flag, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              currency.code,
                              style: TextStyle(
                                color: isSelected
                                    ? OnboardingTheme.primary
                                    : Colors.white.withOpacity(0.7),
                                fontSize: 14,
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

              // أزرار التنقل
              Row(
                children: [
                  // زر الرجوع
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // زر ابدأ الآن
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: selected ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: selected ? _onContinue : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(
                                    colors: [
                                      OnboardingTheme.primary,
                                      Color(0xFF3DB8B0),
                                    ],
                                  )
                                : null,
                            color: selected
                                ? null
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: OnboardingTheme.primary
                                          .withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'التالي',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
