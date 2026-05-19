import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dabdt/features/backup/data/datasources/drive_backup_service.dart';
import 'package:dabdt/features/backup/data/schedulers/background_backup_service.dart';

import '../../shared/theme/onboarding_theme.dart';

class BackupSetupPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const BackupSetupPage({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<BackupSetupPage> createState() => _BackupSetupPageState();
}

class _BackupSetupPageState extends State<BackupSetupPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _isProcessing = false;

  String? _driveEmail;

  bool _driveAutoBackup = false;
  TimeOfDay _driveBackupTime = const TimeOfDay(hour: 3, minute: 0);
  String _driveFrequency = 'يومياً';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('drive_email');
      final emailFromService =
          savedEmail ?? await DriveBackupService.instance.getLinkedEmail();

      if (!mounted) return;
      setState(() {
        _driveEmail = emailFromService;
        _driveAutoBackup = prefs.getBool('drive_auto_backup') ?? false;
        _driveFrequency = prefs.getString('drive_frequency') ?? 'يومياً';
        _driveBackupTime = TimeOfDay(
          hour: prefs.getInt('drive_backup_hour') ?? 3,
          minute: prefs.getInt('drive_backup_minute') ?? 0,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAndApply() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('drive_auto_backup', _driveAutoBackup);
    await prefs.setString('drive_frequency', _driveFrequency);
    await prefs.setInt('drive_backup_hour', _driveBackupTime.hour);
    await prefs.setInt('drive_backup_minute', _driveBackupTime.minute);

    if (_driveAutoBackup) {
      await BackgroundBackupService.scheduleDriveBackup(
        _driveBackupTime,
        frequency: _driveFrequency,
      );
    } else {
      await BackgroundBackupService.cancelDriveBackup();
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _driveBackupTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: OnboardingTheme.primary,
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != _driveBackupTime) {
      setState(() => _driveBackupTime = picked);
      await _saveAndApply();
    }
  }

  Future<void> _pickFrequency() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('اختر التكرار', style: TextStyle(fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final freq in const ['يومياً', 'أسبوعياً', 'شهرياً'])
                RadioListTile<String>(
                  title: Text(freq, style: const TextStyle(fontSize: 12)),
                  value: freq,
                  groupValue: _driveFrequency,
                  onChanged: (value) => Navigator.pop(context, value),
                  dense: true,
                ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result != _driveFrequency) {
      setState(() => _driveFrequency = result);
      await _saveAndApply();
    }
  }

  Future<void> _signIn() async {
    setState(() => _isProcessing = true);
    try {
      final user = await DriveBackupService.instance.signIn();
      if (!mounted) return;
      setState(() {
        _driveEmail = user?.email;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _unlink() async {
    setState(() => _isProcessing = true);
    try {
      await DriveBackupService.instance.unlinkAccount();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('drive_auto_backup', false);
      await BackgroundBackupService.cancelDriveBackup();

      if (!mounted) return;
      setState(() {
        _driveEmail = null;
        _driveAutoBackup = false;
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    final isLinked = (_driveEmail != null && _driveEmail!.isNotEmpty);
    if (value && !isLinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول إلى Google أولاً')),
      );
      return;
    }

    setState(() => _driveAutoBackup = value);
    await _saveAndApply();
  }

  Future<void> _continue() async {
    setState(() => _isProcessing = true);
    try {
      await _saveAndApply();
      if (!mounted) return;
      widget.onContinue();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLinked = (_driveEmail != null && _driveEmail!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // البطاقة الرئيسية
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: OnboardingTheme.primary.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: OnboardingTheme.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.cloud_done,
                                  color: OnboardingTheme.primary,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'احمِ بياناتك بالنسخ الاحتياطي',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'اربط حساب Google لاستخدام النسخ السحابي التلقائي',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.65),
                                  fontFamily: 'Cairo',
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              // تسجيل دخول Google
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isLinked ? Icons.verified_user : Icons.login,
                                        color: isLinked
                                            ? OnboardingTheme.primary
                                            : Colors.white.withOpacity(0.7),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isLinked
                                                ? 'تم الربط'
                                                : 'تسجيل الدخول بحساب Google',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            isLinked
                                                ? (_driveEmail ?? '')
                                                : 'لرفع نسخة احتياطية إلى Drive',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white.withOpacity(0.6),
                                              fontFamily: 'Cairo',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (isLinked)
                                      TextButton(
                                        onPressed: _isProcessing ? null : _unlink,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red.shade300,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'إلغاء',
                                          style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                                        ),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: _isProcessing ? null : _signIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: OnboardingTheme.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: const Text(
                                          'دخول',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // النسخ الاحتياطي التلقائي
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.backup,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'تفعيل النسخ الاحتياطي التلقائي',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.85,
                                      child: Switch(
                                        value: _driveAutoBackup,
                                        onChanged: _isProcessing ? null : _toggleAutoBackup,
                                        activeColor: OnboardingTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _OptionRow(
                                icon: Icons.schedule,
                                title: 'التكرار',
                                subtitle: _driveFrequency,
                                onTap: (_isProcessing || !_driveAutoBackup)
                                    ? null
                                    : _pickFrequency,
                              ),
                              const SizedBox(height: 6),
                              _OptionRow(
                                icon: Icons.access_time,
                                title: 'وقت النسخ',
                                subtitle:
                                    '${_driveBackupTime.hour.toString().padLeft(2, '0')}:${_driveBackupTime.minute.toString().padLeft(2, '0')}',
                                onTap:
                                    (_isProcessing || !_driveAutoBackup) ? null : _selectTime,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 12),
                        // أزرار التحكم
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isProcessing ? null : widget.onSkip,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.12),
                                      ),
                                    ),
                                    child: const Text(
                                      'تخطي',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isProcessing ? null : _continue,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Ink(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [OnboardingTheme.primary, Color(0xFF3DB8B0)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: OnboardingTheme.primary.withOpacity(0.35),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'متابعة',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? onTap;

  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(enabled ? 0.12 : 0.06),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.4),
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: enabled
                            ? Colors.white.withOpacity(0.65)
                            : Colors.white.withOpacity(0.35),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: enabled
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
