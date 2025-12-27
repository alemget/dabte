import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../intro_provider.dart';

class NameSetupPage extends StatefulWidget {
  const NameSetupPage({super.key});

  @override
  State<NameSetupPage> createState() => _NameSetupPageState();
}

class _NameSetupPageState extends State<NameSetupPage> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
        try {
          final provider = Provider.of<IntroProvider>(context, listen: false);
          provider.updateProfile(name: _controller.text.trim());
          provider.setNameReady(hasText);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                    width: i <= 1 ? (i == 1 ? 24 : 8) : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i <= 1 ? const Color(0xFF4ECDC4) : Colors.white24,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Content Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _hasText
                        ? const Color(0xFF4ECDC4).withOpacity(0.5)
                        : Colors.white12,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _hasText ? Icons.person : Icons.person_outline,
                      size: 48,
                      color: _hasText
                          ? const Color(0xFF4ECDC4)
                          : Colors.white54,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'ما اسمك؟',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيظهر في إشعارات التذكير',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasText
                              ? const Color(0xFF4ECDC4).withOpacity(0.5)
                              : Colors.white12,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اكتب اسمك',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),

                    if (_hasText) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4ECDC4),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'أهلاً ${_controller.text.trim()}',
                            style: const TextStyle(
                              color: Color(0xFF4ECDC4),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Swipe hint
              if (_hasText)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      size: 16,
                      color: const Color(0xFF4ECDC4).withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'اسحب للمتابعة',
                      style: TextStyle(
                        color: const Color(0xFF4ECDC4).withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'اكتب اسمك للمتابعة',
                  style: TextStyle(color: Colors.white30, fontSize: 14),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
