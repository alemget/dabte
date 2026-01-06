import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../ui/lock_screen.dart';
import '../ui/main_screen.dart';
import '../ui/splash_screen.dart';
import '../features/onboarding/onboarding.dart';

class App extends StatelessWidget {
  final bool seenIntro;
  const App({super.key, this.seenIntro = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DioMax - ديوماكس',
          locale: languageProvider.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF5C6EF8),
            ),
            useMaterial3: true,
          ),
          home: AppLockWrapper(seenIntro: seenIntro),
        );
      },
    );
  }
}

class AppLockWrapper extends StatefulWidget {
  final bool seenIntro;
  const AppLockWrapper({super.key, required this.seenIntro});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  bool _isLocked = true;
  bool _lockEnabled = false;
  bool _isLoading = true;
  bool _isAuthenticating = false;
  bool _hasUnlocked = false; // Flag to prevent re-locking after unlock
  bool _introCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only lock when app goes to background, not during authentication, and not after unlock
    if (state == AppLifecycleState.paused &&
        !_isAuthenticating &&
        !_hasUnlocked) {
      if (_lockEnabled && !_isLocked) {
        setState(() {
          _isLocked = true;
        });
      }
    } else if (state == AppLifecycleState.resumed && _hasUnlocked) {
      // Ensure we stay unlocked when returning from background after unlock
      setState(() {
        _isLocked = false;
      });
    }
  }

  Future<void> _checkLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lockEnabled = prefs.getBool('lock_enabled') ?? false;

    if (mounted) {
      setState(() {
        _lockEnabled = lockEnabled;
        _isLocked = lockEnabled;
        // If we haven't seen intro, we shouldn't be locked yet, or doesn't matter as we redirect
        _isLoading = false;
      });
    }
  }

  void _unlock() {
    setState(() {
      _isLocked = false;
      _isAuthenticating = false;
      _hasUnlocked = true; // Mark as unlocked
    });
  }

  void _onAuthenticationStarted() {
    setState(() {
      _isAuthenticating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    // TODO: مؤقتاً - إظهار شاشة الترحيب دائماً للتجربة
    // بعد الانتهاء من التجربة، أعد تفعيل الشرط الأصلي:
    // if (!widget.seenIntro) {
    if (true) {
      if (!_introCompleted) {
        return OnboardingFlow(
          onCompleted: () {
            if (mounted) {
              setState(() {
                _introCompleted = true;
              });
            }
          },
        );
      }
    }

    if (_isLocked && _lockEnabled) {
      return LockScreen(
        onUnlocked: _unlock,
        onAuthenticationStarted: _onAuthenticationStarted,
      );
    }

    return const MainScreen();
  }
}
