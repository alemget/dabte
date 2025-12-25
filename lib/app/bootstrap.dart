import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import 'package:dabdt/features/backup/data/schedulers/background_backup_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  BackgroundBackupService.initialize();

  debugPrint('App starting: Initializing NotificationService...');
  NotificationService.instance.initialize().then((_) {
    debugPrint('App starting: NotificationService initialized.');
  });
}
