import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/theme/onboarding_theme.dart';
import '../../shared/widgets/swipe_hint.dart';
import '../setup/onboarding_provider.dart';

class VersePage extends StatefulWidget {
  const VersePage({super.key});

  @override
  State<VersePage> createState() => _VersePageState();
}

class _VersePageState extends State<VersePage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _ready = true);
        context.read<OnboardingProvider>().setVerseReady(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OnboardingTheme.background,
        image: DecorationImage(
          image: AssetImage('assets/images/intro_background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(OnboardingTheme.padding),
        child: Column(
          children: [
            const Spacer(),
            AnimatedOpacity(
              opacity: _ready ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(OnboardingTheme.cardPadding),
                decoration: OnboardingTheme.cardDecoration,
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 56,
                      color: OnboardingTheme.primary.withOpacity(0.85),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ\nإِلَىٰ أَجَلٍ مُّسَمًّى فَاكْتُبُوهُ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Amiri',
                        color: OnboardingTheme.textPrimary,
                        height: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'سورة البقرة - ٢٨٢',
                      style: TextStyle(
                        fontSize: 14,
                        color: OnboardingTheme.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            OnboardingSwipeHint(isVisible: _ready),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
