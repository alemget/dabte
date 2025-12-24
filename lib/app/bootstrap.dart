import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../ui/settings/backup/services/background_backup_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  BackgroundBackupService.initialize();

  debugPrint('App starting: Initializing NotificationService...');
  NotificationService.instance.initialize().then((_) {
    debugPrint('App starting: NotificationService initialized.');
  });
}
