import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'intro_provider.dart';
import 'pages/currency_setup_page.dart';
import 'pages/profile_setup_page.dart';
import 'pages/verse_intro_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntroProvider(),
      child: Consumer<IntroProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: PageView(
              controller: provider.pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              onPageChanged: provider.onPageChanged,
              children: const [
                VerseIntroPage(),
                CurrencySetupPage(),
                ProfileSetupPage(),
                // BackupSetupPage(), // Optional, maybe part of profile or separate
              ],
            ),
          );
        },
      ),
    );
  }
}
