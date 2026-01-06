import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/theme/onboarding_theme.dart';
import '../../shared/widgets/swipe_hint.dart';
import '../setup/onboarding_provider.dart';

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
    final name = _controller.text.trim();
    final hasText = name.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }

    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    provider.updateUserName(name);
    provider.setNameReady(hasText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(OnboardingTheme.padding),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(OnboardingTheme.cardPadding),
            decoration: _hasText
                ? OnboardingTheme.activeCardDecoration
                : OnboardingTheme.cardDecoration,
            child: Column(
              children: [
                Icon(
                  _hasText ? Icons.person : Icons.person_outline,
                  size: 56,
                  color: _hasText
                      ? OnboardingTheme.primary
                      : OnboardingTheme.textSecondary,
                ),
                const SizedBox(height: 24),
                const Text('ما اسمك؟', style: OnboardingTheme.pageTitle),
                const SizedBox(height: 8),
                Text('سيظهر في إشعارات التذكير', style: OnboardingTheme.subtitle),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasText
                          ? OnboardingTheme.primary.withOpacity(0.5)
                          : OnboardingTheme.border,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1a1a2e),
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Cairo',
                    ),
                    decoration: InputDecoration(
                      hintText: 'اكتب اسمك',
                      hintStyle: TextStyle(
                        color: const Color(0xFF1a1a2e).withOpacity(0.4),
                        fontFamily: 'Cairo',
                      ),
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
                        color: OnboardingTheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'أهلاً ${_controller.text.trim()}',
                        style: const TextStyle(
                          color: OnboardingTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          if (_hasText)
            const OnboardingSwipeHint(isVisible: true)
          else
            Text(
              'اكتب اسمك للمتابعة',
              style: TextStyle(
                color: OnboardingTheme.textSecondary.withOpacity(0.7),
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
