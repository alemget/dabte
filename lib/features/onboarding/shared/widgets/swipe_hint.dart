import 'package:flutter/material.dart';

import '../theme/onboarding_theme.dart';

class OnboardingSwipeHint extends StatelessWidget {
  const OnboardingSwipeHint({
    super.key,
    this.isVisible = true,
    this.isLastPage = false,
  });

  final bool isVisible;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox(height: 24);
    }

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back_ios,
            size: 16,
            color: OnboardingTheme.primary.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            isLastPage ? 'اسحب للإنهاء' : 'اسحب للمتابعة',
            style: TextStyle(
              color: OnboardingTheme.primary.withOpacity(0.6),
              fontSize: 14,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
