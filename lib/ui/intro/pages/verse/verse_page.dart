import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../intro_provider.dart';
import '../../theme/intro_theme.dart';
import '../../widgets/swipe_hint.dart';

/// Verse/Welcome page - First page in the onboarding flow
/// Shows the Quran verse about recording debts
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
    // Auto-enable after a brief delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _ready = true);
        context.read<IntroProvider>().setVerseReady(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(IntroTheme.padding),
      child: Column(
        children: [
          const Spacer(),

          // ─────────────────────────────────────────────────────────
          // Verse Card (Placeholder - سيتم تصميمها لاحقاً)
          // ─────────────────────────────────────────────────────────
          AnimatedOpacity(
            opacity: _ready ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(IntroTheme.cardPadding),
              decoration: IntroTheme.cardDecoration,
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 56,
                    color: IntroTheme.primary.withOpacity(0.8),
                  ),
                  const SizedBox(height: 24),

                  // Verse text
                  const Text(
                    'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ\nإِلَىٰ أَجَلٍ مُّسَمًّى فَاكْتُبُوهُ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Amiri',
                      color: IntroTheme.textPrimary,
                      height: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Surah reference
                  Text(
                    'سورة البقرة - ٢٨٢',
                    style: TextStyle(
                      fontSize: 14,
                      color: IntroTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ─────────────────────────────────────────────────────────
          // Swipe Hint
          // ─────────────────────────────────────────────────────────
          SwipeHint(isVisible: _ready),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
