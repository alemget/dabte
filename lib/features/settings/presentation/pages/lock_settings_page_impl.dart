import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LockSettingsPage extends StatefulWidget {
  const LockSettingsPage({super.key});

  @override
  State<LockSettingsPage> createState() => _LockSettingsPageState();
}

class _LockSettingsPageState extends State<LockSettingsPage> {
  bool _lockEnabled = false;
  bool _biometricEnabled = false;
  bool _loading = true;
  bool _biometricAvailable = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _biometricAvailable = canCheck && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        _biometricAvailable = false;
      });
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lockEnabled = prefs.getBool('lock_enabled') ?? false;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _loading = false;
    });
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _setupPin() async {
    final pin = await _showPinSetupDialog();
    if (pin != null && pin.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin_hash', _hashPin(pin));
      await prefs.setBool('lock_enabled', true);
      setState(() {
        _lockEnabled = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تفعيل قفل التطبيق بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<String?> _showPinSetupDialog() async {
    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    String? firstPin;
    
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('إعداد رمز PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (firstPin == null) ...[
                      const Text('أدخل رمز PIN من 4 أرقام', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller1,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          hintText: '••••',
                          counterText: '',
                        ),
                      ),
                    ] else ...[
                      const Text('أعد إدخال رمز PIN', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller2,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        maxLength: 4,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          hintText: '••••',
                          counterText: '',
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (firstPin == null) {
                        // First PIN entry
                        if (controller1.text.length == 4) {
                          setDialogState(() {
                            firstPin = controller1.text;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('رمز PIN يجب أن يكون 4 أرقام'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      } else {
                        // Second PIN entry - confirmation
                        if (controller2.text.length == 4) {
                          if (controller2.text == firstPin) {
                            Navigator.of(context).pop(firstPin);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('رمز PIN غير متطابق، حاول مرة أخرى'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            // Reset
                            setDialogState(() {
                              firstPin = null;
                              controller1.clear();
                              controller2.clear();
                            });
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('رمز PIN يجب أن يكون 4 أرقام'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(firstPin == null ? 'التالي' : 'تأكيد'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _disableLock() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('تعطيل القفل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            content: const Text('هل تريد تعطيل قفل التطبيق؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('تعطيل'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('app_pin_hash');
      await prefs.setBool('lock_enabled', false);
      await prefs.setBool('biometric_enabled', false);
      setState(() {
        _lockEnabled = false;
        _biometricEnabled = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value && _biometricAvailable) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'تأكيد الهوية لتفعيل البصمة',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );

        if (authenticated) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('biometric_enabled', true);
          setState(() {
            _biometricEnabled = true;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('تم تفعيل البصمة بنجاح'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', false);
      setState(() {
        _biometricEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            'قفل التطبيق',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEF4444).withOpacity(0.1),
                            const Color(0xFFF59E0B).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.security, color: Color(0xFFEF4444), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'حماية بياناتك',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'قم بتفعيل رمز PIN أو البصمة لحماية معلوماتك المالية',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Lock settings card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // PIN Lock
                          _SettingTile(
                            icon: Icons.pin,
                            iconColor: const Color(0xFF3B82F6),
                            title: 'رمز PIN',
                            subtitle: _lockEnabled ? 'مفعّل' : 'معطّل',
                            trailing: Switch(
                              value: _lockEnabled,
                              onChanged: (value) {
                                if (value) {
                                  _setupPin();
                                } else {
                                  _disableLock();
                                }
                              },
                              activeColor: Colors.green,
                            ),
                          ),

                          if (_lockEnabled) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 74),
                              child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                            ),

                            // Change PIN
                            _SettingTile(
                              icon: Icons.edit,
                              iconColor: const Color(0xFFF59E0B),
                              title: 'تغيير رمز PIN',
                              subtitle: 'تحديث رمز المرور',
                              onTap: _setupPin,
                            ),

                            if (_biometricAvailable) ...[
                              Padding(
                                padding: const EdgeInsets.only(right: 74),
                                child: Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                              ),

                              // Biometric
                              _SettingTile(
                                icon: Icons.fingerprint,
                                iconColor: const Color(0xFF10B981),
                                title: 'البصمة',
                                subtitle: _biometricEnabled ? 'مفعّلة' : 'معطّلة',
                                trailing: Switch(
                                  value: _biometricEnabled,
                                  onChanged: _toggleBiometric,
                                  activeColor: Colors.green,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    if (!_biometricAvailable && _lockEnabled) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'البصمة غير متاحة على هذا الجهاز',
                                style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
