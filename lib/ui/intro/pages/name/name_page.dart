import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../intro_provider.dart';
import '../../theme/intro_theme.dart';
import '../../widgets/swipe_hint.dart';

/// Name setup page - Second page in the onboarding flow
/// Allows user to enter their name
class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
      try {
        final provider = Provider.of<IntroProvider>(context, listen: false);
        provider.updateProfile(name: _controller.text.trim());
        provider.setNameReady(hasText);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(IntroTheme.padding),
      child: Column(
        children: [
          const Spacer(),

          // ─────────────────────────────────────────────────────────
          // Name Input Card (Placeholder - سيتم تصميمها لاحقاً)
          // ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(IntroTheme.cardPadding),
            decoration: _hasText
                ? IntroTheme.activeCardDecoration
                : IntroTheme.cardDecoration,
            child: Column(
              children: [
                Icon(
                  _hasText ? Icons.person : Icons.person_outline,
                  size: 56,
                  color: _hasText
                      ? IntroTheme.primary
                      : IntroTheme.textSecondary,
                ),
                const SizedBox(height: 24),

                // Title
                const Text('ما اسمك؟', style: IntroTheme.pageTitle),

                const SizedBox(height: 8),

                // Subtitle
                Text('سيظهر في إشعارات التذكير', style: IntroTheme.subtitle),

                const SizedBox(height: 24),

                // Input field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasText
                          ? IntroTheme.primary.withOpacity(0.5)
                          : IntroTheme.border,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: IntroTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسمك',
                      hintStyle: TextStyle(color: IntroTheme.textHint),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),

                // Welcome message
                if (_hasText) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: IntroTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'أهلاً ${_controller.text.trim()}',
                        style: const TextStyle(
                          color: IntroTheme.primary,
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

          // ─────────────────────────────────────────────────────────
          // Swipe Hint or Instruction
          // ─────────────────────────────────────────────────────────
          if (_hasText)
            const SwipeHint(isVisible: true)
          else
            Text(
              'اكتب اسمك للمتابعة',
              style: TextStyle(color: IntroTheme.textHint, fontSize: 14),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
