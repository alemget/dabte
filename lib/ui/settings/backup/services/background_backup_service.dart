export 'package:dabdt/features/backup/data/schedulers/background_backup_service.dart';

/*
// دالة مستوى أعلى (مطلوبة من WorkManager)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // تهيئة الإشعارات
      final notificationsPlugin = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const initSettings = InitializationSettings(android: androidSettings);
      await notificationsPlugin.initialize(initSettings);

      // إنشاء قناة الإشعارات
      const channel = AndroidNotificationChannel(
        'backup_notifications',
        'النسخ الاحتياطي',
        description: 'إشعارات النسخ الاحتياطي التلقائي',
        importance: Importance.high,
      );
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      if (task == localBackupTask) {
        // تنفيذ النسخ المحلي
        final result = await LocalBackupService.instance.createAutoBackup();
        
        await _showNotification(
          notificationsPlugin,
          result.success ? 'تم النسخ الاحتياطي' : 'فشل النسخ الاحتياطي',
          result.success 
              ? 'تم حفظ نسخة احتياطية بنجاح' 
              : (result.errorMessage ?? 'حدث خطأ'),
        );
        
        // إعادة جدولة المهمة التالية (Recursive)
        await BackgroundBackupService.rescheduleLocal();

        return result.success;
      } else if (task == driveBackupTask) {
        // تنفيذ النسخ السحابي
        final signInResult = await DriveBackupService.instance.signIn();
        if (signInResult == null) {
          await _showNotification(
            notificationsPlugin,
            'تنبيه',
            'يرجى فتح التطبيق لتسجيل الدخول لـ Google Drive',
          );
           // نحاول إعادة الجدولة حتى لو فشل الدخول، لعل المستخدم يدخل لاحقاً
          await BackgroundBackupService.rescheduleDriveBackup();
          return false;
        }
 

        final tempResult = await LocalBackupService.instance.createTempBackup();
        if (!tempResult.success || tempResult.filePath == null) {
          await _showNotification(
            notificationsPlugin,
            'فشل النسخ السحابي',
            'تعذر إنشاء ملف النسخة',
          );
          await BackgroundBackupService.rescheduleDriveBackup();
          return false;
        }

        final uploadResult = await DriveBackupService.instance.uploadBackup(tempResult.filePath!);
        
        await _showNotification(
          notificationsPlugin,
          uploadResult.success ? 'تم النسخ إلى Drive' : 'فشل النسخ السحابي',
          uploadResult.success 
              ? 'تم رفع نسخة احتياطية بنجاح' 
              : (uploadResult.errorMessage ?? 'حدث خطأ'),
        );
        
        // إعادة جدولة المهمة التالية (Recursive)
        await BackgroundBackupService.rescheduleDriveBackup();
        
        return uploadResult.success;
      }
      
      return true;
    } catch (e) {
      debugPrint('خطأ في مهمة الخلفية: $e');
      // في حالة حدوث استثناء، نحاول إعادة الجدولة لضمان عدم توقف النظام
      try {
        if (task == localBackupTask) {
            await BackgroundBackupService.rescheduleLocal();
        } else if (task == driveBackupTask) {
            await BackgroundBackupService.rescheduleDriveBackup();
        }
      } catch (e2) {
        debugPrint('فشل إعادة الجدولة بعد الخطأ: $e2');
      }
      return false;
    }
  });
}

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin plugin,
  String title,
  String body,
) async {
  const androidDetails = AndroidNotificationDetails(
    'backup_notifications',
    'النسخ الاحتياطي',
    channelDescription: 'إشعارات النسخ الاحتياطي التلقائي',
    importance: Importance.high,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);
  
  await plugin.show(
    DateTime.now().millisecondsSinceEpoch % 100000,
    title,
    body,
    details,
  );
}

/// خدمة النسخ الاحتياطي في الخلفية - الإصدار الاحترافي المعدل
/// يستخدم نظام جدولة المهام المتكررة يدوياً (Recursive One-Off) لدقة التوقيت
class BackgroundBackupService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // تفعيل وضع التصحيح للتتبع
    );
  }

  static Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }

  /// تشغيل اختبار سريع - مهمة واحدة بعد 30 ثانية
  static Future<void> runQuickTest() async {
    await Workmanager().registerOneOffTask(
      'testBackupTask_${DateTime.now().millisecondsSinceEpoch}', // Unique name for test
      localBackupTask, // reuse the same task logic, but we won't reschedule inside because we check for 'localBackupTask' exact match in dispatcher?
      // Wait, dispatcher checks `if (task == localBackupTask)`. 
      // If we pass 'localBackupTask' as the taskName (2nd arg), dispatcher receives 'localBackupTask'.
      // If we register it with a DIFFERENT uniqueName, it will still run the same code.
      // BUT inside dispatcher, we call rescheduleLocal(). 
      // We don't want the test to trigger a persistent schedule.
      // Problem: dispatch currently checks `if (task == localBackupTask)`. 
      // Workmanager API: executeTask(taskName, inputData). taskName is the 2nd argument of registerOneOffTask.
      // So if we simply use localBackupTask string, it will reschedule.
      // Let's create a separate test task name or input data to prevent rescheduling.
      inputData: {'is_test': true},
      initialDelay: const Duration(seconds: 30),
    );
  }
  
  // Need to update dispatcher to handle 'is_test'
  // Actually, let's keep it simple. If the user runs a test, rescheduling it doesn't hurt much (it just overwrites the schedule).
  // But strictly speaking, a 30s test shouldn't mess with the daily schedule.
  // However, the current dispatcher code calls `rescheduleLocal` which reads from prefs.
  // It will just re-assert the daily schedule. That's actually fine! 
  // It ensures the schedule is alive.

  /// إعادة جدولة النسخ المحلي (يستدعى من الخلفية)
  static Future<void> rescheduleLocal() async {
    final prefs = await SharedPreferences.getInstance();
    // التأكد من أن التفعيل ما زال سارياً
    if (prefs.getBool('local_auto_backup') != true) return;

    final hour = prefs.getInt('local_backup_hour') ?? 2;
    final minute = prefs.getInt('local_backup_minute') ?? 0;
    
    await scheduleLocalBackup(TimeOfDay(hour: hour, minute: minute));
  }

  /// إعادة جدولة النسخ السحابي (يستدعى من الخلفية)
  static Future<void> rescheduleDriveBackup() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('drive_auto_backup') != true) return;

    final hour = prefs.getInt('drive_backup_hour') ?? 3;
    final minute = prefs.getInt('drive_backup_minute') ?? 0;
    
    await scheduleDriveBackup(TimeOfDay(hour: hour, minute: minute));
  }

  /// جدولة النسخ الاحتياطي المحلي اليومي
  static Future<void> scheduleLocalBackup(TimeOfDay time) async {
    // إلغاء أي مهمة سابقة بنفس الاسم لضمان عدم التكرار
    await Workmanager().cancelByUniqueName(localBackupTask);
    
    // حساب التأخير حتى الوقت المحدد
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    // إذا كان الوقت المحدد قد مضى لليوم، نجدول لليوم التالي
    // أو إذا كان الوقت قريباً جداً (مثلاً أثناء التنفيذ)، ننتقل لغد
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    final delay = scheduledTime.difference(now);
    
    debugPrint('جدولة النسخ المحلي القادم في: $scheduledTime (بعد ${delay.inMinutes} دقيقة)');

    // حفظ وقت الجدولة
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('next_local_backup', scheduledTime.toIso8601String());
    
    // استخدام OneOffTask بدلاً من PeriodicTask
    await Workmanager().registerOneOffTask(
      localBackupTask, // UniqueName
      localBackupTask, // TaskName
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace, // استبدال القديم إذا وجد
      constraints: Constraints(
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// جدولة النسخ الاحتياطي السحابي اليومي
  static Future<void> scheduleDriveBackup(TimeOfDay time) async {
    await Workmanager().cancelByUniqueName(driveBackupTask);
    
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    final delay = scheduledTime.difference(now);
    
    debugPrint('جدولة النسخ السحابي القادم في: $scheduledTime (بعد ${delay.inMinutes} دقيقة)');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('next_drive_backup', scheduledTime.toIso8601String());
    
    await Workmanager().registerOneOffTask(
      driveBackupTask,
      driveBackupTask,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.connected, // يتطلب انترنت
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  /// إلغاء النسخ الاحتياطي المحلي
  static Future<void> cancelLocalBackup() async {
    await Workmanager().cancelByUniqueName(localBackupTask);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('next_local_backup');
  }

  /// إلغاء النسخ الاحتياطي السحابي
  static Future<void> cancelDriveBackup() async {
    await Workmanager().cancelByUniqueName(driveBackupTask);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('next_drive_backup');
  }

  /// اختبار الإشعارات
  static Future<void> showTestNotification() async {
    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      'backup_notifications',
      'النسخ الاحتياطي',
      description: 'إشعارات النسخ الاحتياطي التلقائي',
      importance: Importance.high,
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _showNotification(
      notificationsPlugin,
      'تجربة ناجحة',
      'نظام الإشعارات يعمل بشكل صحيح',
    );
  }
}

 */
