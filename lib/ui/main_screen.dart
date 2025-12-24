import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import 'clients/clients_list/clients_page.dart';
import 'settings/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _pages = const [ClientsPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRTL = AppLocalizations.of(context)!.localeName.startsWith('ar');
    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.people_alt_outlined),
              label: l10n.clients,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
