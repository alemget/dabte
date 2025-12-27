import 'package:flutter/material.dart';
import '../theme/intro_theme.dart';

/// Page indicator widget showing current page position
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index <= currentPage;
        final isCurrent = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isActive ? IntroTheme.primary : IntroTheme.border,
          ),
        );
      }),
    );
  }
}
