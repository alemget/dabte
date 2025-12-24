import 'package:flutter/material.dart';

class NotificationsSettingsPage extends StatelessWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإشعارات'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('هنا مستقبلاً إعدادات تنبيهات الديون والإشعارات.'),
        ),
      ),
    );
  }
}
