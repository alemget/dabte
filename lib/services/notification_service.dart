import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/transaction.dart';
import '../models/client.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// تهيئة الخدمة
  Future<bool> initialize() async {
    // نتحقق دائمًا، حتى لو تمت التهيئة سابقًا، للتأكد من القنوات
    debugPrint('Initializing NotificationService...');

    try {
      // 1. تهيئة بيانات المنطقة الزمنية (Critical)
      tz_data.initializeTimeZones();
      await _configureLocalTimeZone();

      // 2. إعدادات المنصات
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked payload: ${details.payload}');
        },
      );

      debugPrint('NotificationService initialization result: $initialized');

      // 3. إنشاء القناة (Android) - ضروري جدًا
      await _createNotificationChannel();

      _isInitialized = initialized ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      return false;
    }
  }

  /// إعداد المنطقة الزمنية المحلية بدقة
  Future<void> _configureLocalTimeZone() async {
    try {
      final dynamic timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timeZoneInfo.toString();
      debugPrint('Configured local timezone (flutter_timezone): $timeZoneName');
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (locationError) {
        debugPrint(
          'Location $timeZoneName not found in database. Trying fallback...',
        );
        // Fallback for offsets like "GMT+03:00" usually not supported by timezone package directly
        // We stick to a safe default for the region
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      }
    } catch (e) {
      debugPrint('Error getting local timezone: $e');
      // Fallback
      try {
        debugPrint('Fallback to Asia/Riyadh');
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      } catch (_) {}
    }
  }

  /// إنشاء قناة الإشعارات - التأكد منها قبل كل عملية جدولة
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'debt_reminders',
      'تذكيرات الديون',
      description: 'إشعارات تذكير بالديون المستحقة',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// إرسال إشعار فوري للتجربة
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    // إعادة التهيئة لضمان القنوات
    await initialize();

    // تأكد من الأذونات
    if (!await requestPermissions()) {
      debugPrint('Permissions denied for instant notification');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'debt_reminders',
      'تذكيرات الديون',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      category: AndroidNotificationCategory.reminder,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  /// طلب الأذونات
  Future<bool> requestPermissions() async {
    debugPrint('Requesting permissions...');

    // 1. Notification Permission (Android 13+)
    if (await _isAndroid13OrHigher()) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        debugPrint('Notification permission denied/unknown, requesting...');
        status = await Permission.notification.request();
        if (!status.isGranted) {
          debugPrint('Notification permission NOT granted.');
          // يمكننا إرجاع فرصة للمحاولة ومع ذلك الاستمرار (لأن بعض الأجهزة قد تعمل)
          // لكن الأفضل أن نكون صريحين
        }
      }
    }

    // 2. Exact Alarm Permission (Android 12+)
    if (await _needsExactAlarmPermission()) {
      var alarmStatus = await Permission.scheduleExactAlarm.status;
      if (!alarmStatus.isGranted) {
        debugPrint('ScheduleExactAlarm permission denied, requesting...');
        // On Android 12+, this might not show a dialog but redirects to settings or returns denied
        alarmStatus = await Permission.scheduleExactAlarm.request();
        if (!alarmStatus.isGranted) {
          debugPrint('ScheduleExactAlarm permission NOT granted.');
        }
      }
    }

    return true; // نحاول دائماً الاستمرار
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 33;
    }
    return false;
  }

  Future<bool> _needsExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 31; // Android 12+
    }
    return false;
  }

  /// جدولة تذكير لدين
  Future<void> scheduleDebtReminder({
    required DebtTransaction transaction,
    required Client client,
    required DateTime scheduledTime,
  }) async {
    debugPrint('--- Starting Schedule Debt Reminder ---');

    // 1. إعادة التهيئة للتأكد من القناة
    await initialize();

    // 2. طلب الأذونات صراحة قبل الجدولة
    await requestPermissions();

    final notificationId =
        transaction.id ?? DateTime.now().millisecondsSinceEpoch % 100000;
    final typeText = transaction.isForMe
        ? 'لك عند ${client.name}'
        : 'عليك لـ ${client.name}';

    // تأكد من ضبط الـ TimeZone
    try {
      tz.local; // Test access
    } catch (_) {
      debugPrint('TimeZone.local was not set! Re-configuring...');
      await _configureLocalTimeZone();
    }

    // تحويل الوقت إلى المنطقة الزمنية المحلية المعتمدة
    var tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final nowTz = tz.TZDateTime.now(tz.local);

    // التحقق من الوقت
    if (tzScheduledTime.isBefore(nowTz)) {
      debugPrint(
        'Scheduled time $tzScheduledTime is in the past (Now: $nowTz). Cannot schedule.',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'debt_reminders',
      'تذكيرات الديون',
      channelDescription: 'إشعارات تذكير بالديون المستحقة',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      category: AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(
        '${transaction.amount.toStringAsFixed(2)} ${transaction.currency} $typeText\n${transaction.details}',
      ),
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    try {
      debugPrint(
        'Scheduling for ID: $notificationId at $tzScheduledTime (Local)',
      );

      // المحاولة الأولى: جدولة دقيقة (Exact)
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        'تذكير بدين 💰',
        '${transaction.amount.toStringAsFixed(2)} ${transaction.currency} $typeText',
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'transaction_id:${transaction.id}',
      );

      debugPrint('Notification scheduled successfully (Exact).');
    } catch (e) {
      debugPrint('Error scheduling exact notification: $e');

      // Fallback: جدولة غير دقيقة (Inexact) - تعمل بدون إذن Exact Alarm
      try {
        debugPrint('Attempting fallback scheduling (inexact)...');
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          'تذكير بدين 💰',
          '${transaction.amount.toStringAsFixed(2)} ${transaction.currency} $typeText',
          tzScheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'transaction_id:${transaction.id}',
        );
        debugPrint('Fallback notification scheduled successfully');
      } catch (fallbackError) {
        debugPrint('Fallback scheduling failed: $fallbackError');
        debugPrintStack();
        throw fallbackError;
      }
    }
  }

  /// إلغاء تذكير
  Future<void> cancelReminder(int id) async {
    try {
      debugPrint('Canceling notification ID: $id');
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }
}
