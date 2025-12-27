import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../intro_provider.dart';

class VerseIntroPage extends StatefulWidget {
  const VerseIntroPage({super.key});

  @override
  State<VerseIntroPage> createState() => _VerseIntroPageState();
}

class _VerseIntroPageState extends State<VerseIntroPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _ready = true);
        context.read<IntroProvider>().setVerseReady(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 0 ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i == 0 ? const Color(0xFF4ECDC4) : Colors.white24,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Verse Card
              AnimatedOpacity(
                opacity: _ready ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: const Color(0xFF4ECDC4).withOpacity(0.8),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ\nإِلَىٰ أَجَلٍ مُّسَمًّى فَاكْتُبُوهُ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Amiri',
                          color: Colors.white,
                          height: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'سورة البقرة - ٢٨٢',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Swipe hint
              if (_ready)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 16, color: Colors.white38),
                    const SizedBox(width: 8),
                    Text(
                      'اسحب للمتابعة',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
