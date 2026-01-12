import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/theme/onboarding_theme.dart';
import 'onboarding_provider.dart';

import '../pages/name_page.dart';
import '../pages/currency_page.dart';
import '../pages/secondary_currencies_page.dart';
import '../pages/backup_setup_page.dart';

class OnboardingShell extends StatelessWidget {
  final VoidCallback onCompleted;

  const OnboardingShell({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: _OnboardingShellContent(onCompleted: onCompleted),
    );
  }
}

class _OnboardingShellContent extends StatelessWidget {
  final VoidCallback onCompleted;

  const _OnboardingShellContent({required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // الشريط العلوي مع الشعار والمؤشر
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                children: [
                  // عنوان التطبيق
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [OnboardingTheme.primary, Color(0xFF3DB8B0)],
                        ).createShader(bounds),
                        child: const Text(
                          'ديوماكس',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // مؤشر التقدم المحسن
                  _buildProgressIndicator(provider.currentPage),
                ],
              ),
            ),

            // محتوى الصفحات
            Expanded(
              child: PageView(
                controller: provider.pageController,
                physics: const NeverScrollableScrollPhysics(), // تعطيل السحب
                onPageChanged: provider.onPageChanged,
                children: [
                  const NamePage(),
                  CurrencyPage(
                    onCompleted: () => provider.pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  SecondaryCurrenciesPage(
                    onCompleted: () => provider.pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    ),
                  ),
                  BackupSetupPage(
                    onSkip: () => provider.complete().then((_) => onCompleted()),
                    onContinue: () =>
                        provider.complete().then((_) => onCompleted()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(
          step: 1,
          label: 'الاسم',
          isActive: currentPage >= 0,
          isCompleted: currentPage > 0,
        ),
        _buildProgressLine(isActive: currentPage > 0),
        _buildStepIndicator(
          step: 2,
          label: 'العملة',
          isActive: currentPage >= 1,
          isCompleted: currentPage > 1,
        ),
        _buildProgressLine(isActive: currentPage > 1),
        _buildStepIndicator(
          step: 3,
          label: 'إضافية',
          isActive: currentPage >= 2,
          isCompleted: currentPage > 2,
        ),
        _buildProgressLine(isActive: currentPage > 2),
        _buildStepIndicator(
          step: 4,
          label: 'نسخ',
          isActive: currentPage >= 3,
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isCompleted
                ? OnboardingTheme.primary
                : isActive
                ? OnboardingTheme.primary.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? OnboardingTheme.primary
                  : Colors.white.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive
                          ? OnboardingTheme.primary
                          : Colors.white.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? OnboardingTheme.primary
                : Colors.white.withOpacity(0.4),
            fontSize: 12,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine({required bool isActive}) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isActive
            ? OnboardingTheme.primary
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
