import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'intro_provider.dart';
import 'theme/intro_theme.dart';
import 'widgets/page_indicator.dart';
import 'pages/verse/verse_page.dart';
import 'pages/name/name_page.dart';
import 'pages/currency/currency_page.dart';

/// Main shell/container for the intro/onboarding flow
/// Contains the app header, page indicator, and houses all sub-pages
class IntroShell extends StatelessWidget {
  const IntroShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntroProvider(),
      child: const _IntroShellContent(),
    );
  }
}

class _IntroShellContent extends StatelessWidget {
  const _IntroShellContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IntroProvider>();

    return Scaffold(
      backgroundColor: IntroTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────
            // Header Section
            // ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                children: [
                  // App Title
                  const Text('ديوني', style: IntroTheme.appTitle),

                  const SizedBox(height: 12),

                  // Page Indicator
                  PageIndicator(
                    currentPage: provider.currentPage,
                    totalPages: 3,
                  ),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────────────
            // Pages Section
            // ─────────────────────────────────────────────────────────
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Detect swipe past last page
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    if (provider.currentPage == 2 &&
                        provider.currencyReady &&
                        metrics.pixels >= metrics.maxScrollExtent) {
                      provider.completeIntro(context);
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
                  children: const [VersePage(), NamePage(), CurrencyPage()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
