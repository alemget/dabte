import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/theme/onboarding_theme.dart';
import '../../shared/widgets/page_indicator.dart';
import 'onboarding_provider.dart';
import '../pages/verse_page.dart';
import '../pages/name_page.dart';
import '../pages/currency_page.dart';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  const Text('ديوني', style: OnboardingTheme.appTitle),
                  const SizedBox(height: 12),
                  OnboardingPageIndicator(
                    currentPage: provider.currentPage,
                    totalPages: 3,
                  ),
                ],
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    if (provider.currentPage == 2 &&
                        provider.currencyReady &&
                        metrics.pixels >= metrics.maxScrollExtent) {
                      provider.complete().then((_) => onCompleted());
                    }
                  }
                  return false;
                },
                child: PageView(
                  controller: provider.pageController,
                  physics: provider.canSwipe
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  onPageChanged: provider.onPageChanged,
                  children: [
                    const VersePage(),
                    const NamePage(),
                    CurrencyPage(onCompleted: onCompleted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
