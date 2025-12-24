import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/l10n/app_localizations.dart';

import '../../../../providers/language_provider.dart';
import 'about_app_page.dart';
import 'backup/backup_page.dart';
import 'currencies_page.dart';
import 'language_settings_page.dart';
import 'lock_settings_page.dart';
import 'notifications_settings_page.dart';
import 'personal_profile_page.dart';
import '../widgets/section_title.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_divider.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            l10n.settingsTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
                    // قسم الحساب والأمان
                    SectionTitle(
                      icon: Icons.shield_outlined,
                      title: l10n.security,
                    ),
                    const SizedBox(height: 12),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          icon: Icons.person_outline_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          title: l10n.personalInfo,
                          subtitle: l10n.personalInfoSubtitle,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PersonalProfilePage(),
                            ),
                          ),
                        ),
                        const SettingsDivider(),
                        SettingsTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: l10n.appLock,
                          subtitle: l10n.biometricAuth,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LockSettingsPage(),
                            ),
                          ),
                        ),
                        const SettingsDivider(),
                        SettingsTile(
                          icon: Icons.backup_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: l10n.backup,
                          subtitle: l10n.backupAndRestore,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BackupPage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // قسم التخصيص
                    SectionTitle(
                      icon: Icons.tune_rounded,
                      title: l10n.general,
                    ),
                    const SizedBox(height: 12),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          icon: Icons.attach_money_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: l10n.currencies,
                          subtitle: l10n.manageCurrencies,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CurrenciesPage(),
                            ),
                          ),
                        ),
                        const SettingsDivider(),
                        SettingsTile(
                          icon: Icons.notifications_none_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: l10n.notifications,
                          subtitle: l10n.alertsReminders,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsSettingsPage(),
                            ),
                          ),
                        ),
                        const SettingsDivider(),
                        SettingsTile(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF06B6D4),
                          title: l10n.language,
                          subtitle: languageProvider.isArabic ? l10n.arabic : l10n.english,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LanguageSettingsPage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // قسم المعلومات
                    SectionTitle(
                      icon: Icons.info_outline_rounded,
                      title: l10n.about,
                    ),
                    const SizedBox(height: 12),
                    SettingsCard(
                      children: [
                        SettingsTile(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF64748B),
                          title: l10n.about,
                          subtitle: l10n.versionDeveloper,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutAppPage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // معلومات الإصدار في الأسفل
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 32,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.appTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.versionNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}
