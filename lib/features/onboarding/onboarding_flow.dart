import 'package:flutter/material.dart';

import 'presentation/pages/welcome_screen.dart';
import 'presentation/setup/onboarding_shell.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingFlow({super.key, required this.onCompleted});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  bool _welcomeDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_welcomeDone) {
      return WelcomeScreen(
        onFinished: () {
          setState(() {
            _welcomeDone = true;
          });
        },
      );
    }

    return OnboardingShell(onCompleted: widget.onCompleted);
  }
}
