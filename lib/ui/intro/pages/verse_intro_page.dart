import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../intro_provider.dart';

class VerseIntroPage extends StatefulWidget {
  const VerseIntroPage({super.key});

  @override
  State<VerseIntroPage> createState() => _VerseIntroPageState();
}

class _VerseIntroPageState extends State<VerseIntroPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Deep dark gradient background
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF1E293B), // Slate 800
              Color(0xFF020617), // Slate 950
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Ambient background glow
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFFF59E0B,
                    ).withOpacity(0.05), // Amber glow
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.05),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with pulse
                      Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withOpacity(0.3),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF59E0B).withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              size: 48,
                              color: Color(0xFFF59E0B), // Amber 500
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .boxShadow(blurRadius: 20, duration: 2.seconds)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 2.seconds,
                          ),

                      const SizedBox(height: 48),

                      // Verse Text
                      AnimatedCrossFade(
                        firstChild: _buildVerseText(
                          'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ إِلَىٰ أَجَلٍ مُّسَمًّى فَاكْتُبُوهُ',
                          fontSize: 26,
                          isFull: false,
                        ),
                        secondChild: _buildVerseText(
                          'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنتُم بِدَيْنٍ إِلَىٰ أَجَلٍ مُّسَمًّى فَاكْتُبُوهُ ۚ وَلْيَكْتُب بَّيْنَكُمْ كَاتِبٌ بِالْعَدْلِ ۚ وَلَا يَأْبَ كَاتِبٌ أَن يَكْتُبَ كَمَا عَلَّمَهُ اللَّهُ ۚ فَلْيَكْتُبْ وَلْيُمْلِلِ الَّذِي عَلَيْهِ الْحَقُّ وَلْيَتَّقِ اللَّهَ رَبَّهُ وَلَا يَبْخَسْ مِنْهُ شَيْئًا',
                          fontSize: 18,
                          isFull: true,
                        ),
                        crossFadeState: _isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: 1200.ms,
                        sizeCurve: Curves.easeInOut,

                        alignment: Alignment.center,
                      ),

                      const SizedBox(height: 24),

                      // Source
                      Text(
                        '[البقرة: 282]',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ).animate().fadeIn(delay: 1.seconds, duration: 800.ms),

                      const SizedBox(height: 60),

                      // Actions
                      if (!_isExpanded)
                        SizedBox(
                              height: 60,
                              width: 60,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {
                                  setState(() {
                                    _isExpanded = true;
                                  });
                                },
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white54,
                                  size: 32,
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .moveY(
                              begin: 0,
                              end: 10,
                              duration: 1200.ms,
                              curve: Curves.easeInOut,
                            )
                      else
                        ElevatedButton(
                              onPressed: () {
                                context.read<IntroProvider>().nextPage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFF59E0B,
                                ), // Amber 500
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'بسم الله نبدأ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 20, end: 0, duration: 600.ms)
                            .shimmer(
                              delay: 1.seconds,
                              duration: 1.5.seconds,
                              color: Colors.white.withOpacity(0.5),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseText(
    String text, {
    required double fontSize,
    required bool isFull,
  }) {
    // Split for typewriter effect if it's the short version,
    // or just fade in lines for full version to avoid too much movement

    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFF8FAFC), // Slate 50
            fontSize: fontSize,
            fontFamily: 'Amiri', // Classic Arabic font
            height: 1.8,
            shadows: [
              Shadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).saturate(duration: 2.seconds);
  }
}
