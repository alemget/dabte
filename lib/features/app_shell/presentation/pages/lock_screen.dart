import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  final VoidCallback? onAuthenticationStarted;

  const LockScreen({
    super.key,
    required this.onUnlocked,
    this.onAuthenticationStarted,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _pin = '';
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (biometricEnabled) {
      try {
        final canCheck = await _localAuth.canCheckBiometrics;
        final isDeviceSupported = await _localAuth.isDeviceSupported();
        setState(() {
          _biometricAvailable = canCheck && isDeviceSupported;
          _biometricEnabled = biometricEnabled;
        });
      } catch (e) {
        setState(() {
          _biometricAvailable = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    widget.onAuthenticationStarted?.call();

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: AppLocalizations.of(context)!.confirmIdentity,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          widget.onUnlocked();
        }
      }
    } catch (e) {
      // Biometric failed, user can use PIN
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _verifyPin() async {
    if (_pin.length != 4) return;

    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString('app_pin_hash');

    if (savedHash == null) {
      widget.onUnlocked();
      return;
    }

    final enteredHash = _hashPin(_pin);

    if (enteredHash == savedHash) {
      widget.onUnlocked();
    } else {
      _shakeController.forward(from: 0);
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.error;
        _pin = '';
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _errorMessage = '';
          });
        }
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A),
                Color(0xFF3B82F6),
                Color(0xFF60A5FA),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),

                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(context)!.unlockApp,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 40),

                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _pin.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                isFilled ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 24,
                  child: _errorMessage.isNotEmpty
                      ? Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _buildKeypadRow(['1', '2', '3']),
                      const SizedBox(height: 16),
                      _buildKeypadRow(['4', '5', '6']),
                      const SizedBox(height: 16),
                      _buildKeypadRow(['7', '8', '9']),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_biometricEnabled && _biometricAvailable)
                            _KeypadButton(
                              icon: Icons.fingerprint,
                              onPressed: _authenticateWithBiometric,
                            )
                          else
                            const SizedBox(width: 70, height: 70),

                          _KeypadButton(
                            text: '0',
                            onPressed: () => _onNumberPressed('0'),
                          ),

                          _KeypadButton(
                            icon: Icons.backspace_outlined,
                            onPressed: _onDeletePressed,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((number) {
        return _KeypadButton(
          text: number,
          onPressed: () => _onNumberPressed(number),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback onPressed;

  const _KeypadButton({
    this.text,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(35),
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: text != null
                ? Text(
                    text!,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }
}
