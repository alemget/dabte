import 'package:flutter/material.dart';

import 'intro_shell.dart';

/// Entry point for the intro/onboarding flow
/// Simply exports the IntroShell which contains all the logic
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntroShell();
  }
}
