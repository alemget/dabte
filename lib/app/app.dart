import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../features/app_shell/presentation/pages/lock_screen.dart';
import '../features/app_shell/presentation/pages/main_screen.dart';
import '../features/app_shell/presentation/pages/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Debt Max - ديوني ماكس',
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
          home: const AppLockWrapper(),
        );
      },
    );
  }
}

class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key});

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

    if (_isLocked && _lockEnabled) {
      return LockScreen(
        onUnlocked: _unlock,
        onAuthenticationStarted: _onAuthenticationStarted,
      );
    }

    return const MainScreen();
  }
}
