import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import 'package:dabdt/features/backup/presentation/widgets/backup_action_button.dart';
import 'package:dabdt/features/backup/presentation/widgets/backup_list_widget.dart';
import 'package:dabdt/features/backup/data/datasources/local_backup_service.dart';
import 'package:dabdt/features/backup/data/datasources/drive_backup_service.dart';
import 'package:dabdt/features/backup/data/managers/backup_file_manager.dart';
import 'package:dabdt/features/backup/domain/entities/backup_metadata.dart';
import 'package:dabdt/features/backup/data/schedulers/background_backup_service.dart';
import 'package:dabdt/providers/client_provider.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _isProcessing = false;
  String _processStatus = ''; // لعرض حالة العملية
  String? _driveEmail;
  String? _lastDriveBackup;

  // إعدادات النسخ التلقائي المحلي
  bool _localAutoBackup = false;
  String _localFrequency = 'يومياً';
  String _localBackupPath = '';
  TimeOfDay _localBackupTime = const TimeOfDay(hour: 2, minute: 0);

  // إعدادات النسخ التلقائي لـ Drive
  bool _driveAutoBackup = false;
  String _driveFrequency = 'يومياً';
  TimeOfDay _driveBackupTime = const TimeOfDay(hour: 3, minute: 0);

  // مفتاح لتحديث قائمة النسخ
  final GlobalKey<State> _backupListKey = GlobalKey();

  Future<void> _refreshClientsAfterRestore() async {
    if (!mounted) return;
    try {
      await context.read<ClientProvider>().loadClients(forceRefresh: true);
    } catch (e, stackTrace) {
      debugPrint('Error refreshing clients after restore: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkInternetConnection();
    BackgroundBackupService.initialize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _localBackupPath =
          prefs.getString('local_backup_path') ??
          '/storage/emulated/0/DioMaxBackups';
      _localAutoBackup = prefs.getBool('local_auto_backup') ?? false;
      _localFrequency = prefs.getString('local_frequency') ?? 'يومياً';

      _driveEmail = prefs.getString('drive_email');
      // محاولة استرجاع البريد من الخدمة إذا لم يكن محفوظاً
      if (_driveEmail == null) {
        DriveBackupService.instance.getLinkedEmail().then((email) {
          if (email != null && mounted) {
            setState(() => _driveEmail = email);
          }
        });
      }

      _driveAutoBackup = prefs.getBool('drive_auto_backup') ?? false;
      _driveFrequency = prefs.getString('drive_frequency') ?? 'يومياً';
      _lastDriveBackup = prefs.getString('drive_last_backup');

      _localBackupTime = TimeOfDay(
        hour: prefs.getInt('local_backup_hour') ?? 2,
        minute: prefs.getInt('local_backup_minute') ?? 0,
      );
      _driveBackupTime = TimeOfDay(
        hour: prefs.getInt('drive_backup_hour') ?? 3,
        minute: prefs.getInt('drive_backup_minute') ?? 0,
      );
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_backup_path', _localBackupPath);
    await prefs.setBool('local_auto_backup', _localAutoBackup);
    await prefs.setString('local_frequency', _localFrequency);

    await prefs.setBool('drive_auto_backup', _driveAutoBackup);
    await prefs.setString('drive_frequency', _driveFrequency);

    // حفظ التوقيت
    await prefs.setInt('local_backup_hour', _localBackupTime.hour);
    await prefs.setInt('local_backup_minute', _localBackupTime.minute);
    await prefs.setInt('drive_backup_hour', _driveBackupTime.hour);
    await prefs.setInt('drive_backup_minute', _driveBackupTime.minute);

    // تحديث الجدولة في الخلفية
    if (_localAutoBackup) {
      await BackgroundBackupService.scheduleLocalBackup(
        _localBackupTime,
        frequency: _localFrequency,
      );
    } else {
      await BackgroundBackupService.cancelLocalBackup();
    }

    if (_driveAutoBackup) {
      await BackgroundBackupService.scheduleDriveBackup(
        _driveBackupTime,
        frequency: _driveFrequency,
      );
    } else {
      await BackgroundBackupService.cancelDriveBackup();
    }
  }

  Future<void> _selectTime(bool isLocal) async {
    final initialTime = isLocal ? _localBackupTime : _driveBackupTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF3B82F6), // header background color
                onPrimary: Colors.white, // header text color
                onSurface: Colors.black, // body text color
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != initialTime) {
      setState(() {
        if (isLocal) {
          _localBackupTime = picked;
        } else {
          _driveBackupTime = picked;
        }
      });
      await _saveSettings();
    }
  }

  /// فحص الاتصال بالإنترنت
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> _performLocalBackup() async {
    // الحصول على المسار الافتراضي واسم الملف
    final defaultPath = await LocalBackupService.instance
        .getDefaultBackupPath();
    final defaultFileName = BackupFileManager.instance.generateBackupFileName();

    // عرض مربع حوار تأكيد النسخ الاحتياطي
    final result = await _showBackupConfirmationDialog(
      initialPath: defaultPath,
      initialFileName: defaultFileName,
    );

    if (result == null) return; // تم الإلغاء

    setState(() {
      _isProcessing = true;
      _processStatus = 'جاري إنشاء النسخة المحلية...';
    });

    try {
      // إنشاء النسخة الاحتياطية مع المسار والاسم المحددين
      final backupResult = await LocalBackupService.instance
          .createBackupWithName(result['path']!, result['fileName']!);

      if (backupResult.success && backupResult.filePath != null) {
        // عرض حوار النجاح مع خيار المشاركة
        _showBackupSuccessDialog(
          backupResult.metadata?.fileName ?? result['fileName']!,
          backupResult.filePath!,
        );

        // تحديث قائمة النسخ
        setState(() {});
      } else {
        _showErrorDialog(
          'فشل إنشاء النسخة الاحتياطية',
          backupResult.errorMessage ?? 'حدث خطأ غير متوقع',
        );
      }
    } catch (e) {
      print('خطأ في النسخ الاحتياطي: $e');
      _showErrorDialog(
        'حدث خطأ غير متوقع',
        'حدث خطأ أثناء محاولة إنشاء النسخة الاحتياطية.\n\nالخطأ: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isProcessing = false;
        _processStatus = '';
      });
    }
  }

  /// عرض مربع حوار تأكيد النسخ الاحتياطي
  Future<Map<String, String>?> _showBackupConfirmationDialog({
    required String initialPath,
    required String initialFileName,
  }) async {
    String currentPath = initialPath;
    final fileNameController = TextEditingController(text: initialFileName);

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.save_alt,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'نسخ احتياطي محلي',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'سيتم إنشاء نسخة احتياطية مشفرة من بياناتك',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // مكان التخزين
                  const Text(
                    'مكان التخزين:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final selectedDirectory = await FilePicker.platform
                          .getDirectoryPath();
                      if (selectedDirectory != null) {
                        setDialogState(() {
                          currentPath = selectedDirectory;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder,
                            size: 18,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPath.split('/').last.isEmpty
                                      ? 'DioMaxBackups'
                                      : currentPath.split('/').last,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentPath,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'تغيير',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // اسم الملف
                  const Text(
                    'اسم الملف:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: fileNameController,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.insert_drive_file,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      hintText: 'اسم الملف',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ملاحظة
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'يمكنك استخدام أي اسم تريده للملف',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  String fileName = fileNameController.text.trim();
                  if (fileName.isEmpty) {
                    fileName = initialFileName;
                  }
                  // إضافة الامتداد إذا لم يكن موجوداً
                  if (!fileName.endsWith('.db') && !fileName.endsWith('.dbk')) {
                    fileName = '$fileName.db';
                  }
                  Navigator.pop(context, {
                    'path': currentPath,
                    'fileName': fileName,
                  });
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('موافق', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBackupSuccessDialog(String fileName, String filePath) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'تم النسخ الاحتياطي بنجاح',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'تم نسخ الملف أيضاً إلى:\nDownload/DioMaxBackups',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'يمكنك الآن رؤية النسخة من مدير الملفات في مجلد Downloads',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Share.shareXFiles([
                  XFile(filePath),
                ], text: 'نسخة احتياطية: $fileName');
              },
              icon: const Icon(Icons.share, size: 16),
              label: const Text('مشاركة', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Android 11+ لا يحتاج أذونات لأننا نستخدم SAF
        if (sdkInt >= 30) {
          return true;
        }

        // Android 10 وأقل يحتاج أذونات التخزين
        final status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          final result = await Permission.storage.request();
          if (result.isGranted) {
            return true;
          }
        }

        if (status.isPermanentlyDenied) {
          if (mounted) {
            final shouldOpen = await _showPermissionDialog();
            if (shouldOpen == true) {
              await openAppSettings();
            }
          }
          return false;
        }

        return false;
      }

      return true;
    } catch (e) {
      print('خطأ في طلب الأذونات: $e');
      return true;
    }
  }

  Future<bool?> _showPermissionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('أذونات التخزين', style: TextStyle(fontSize: 14)),
          content: const Text(
            'يحتاج التطبيق إلى أذونات التخزين لحفظ النسخ الاحتياطية. هل تريد فتح الإعدادات؟',
            style: TextStyle(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'فتح الإعدادات',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// طلب أذونات التخزين الكاملة (بما فيها MANAGE_EXTERNAL_STORAGE للأندرويد 11+)
  Future<bool> _requestFullStoragePermission() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Android 13+ (API 33+)
      if (sdkInt >= 33) {
        // طلب أذونات الوسائط
        final photosStatus = await Permission.photos.request();
        final videosStatus = await Permission.videos.request();
        final audioStatus = await Permission.audio.request();

        // إذا تم منح أي منها، نعتبر أن لدينا وصول
        if (photosStatus.isGranted ||
            videosStatus.isGranted ||
            audioStatus.isGranted) {
          return true;
        }

        // محاولة طلب manageExternalStorage
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) {
          return true;
        }

        // عرض حوار لطلب الإذن
        if (mounted) {
          final shouldRequest = await _showManageStorageDialog();
          if (shouldRequest == true) {
            final result = await Permission.manageExternalStorage.request();
            return result.isGranted;
          }
        }

        // حتى بدون الأذونات، FilePicker يجب أن يعمل
        return true;
      }

      // Android 11 & 12 (API 30-32)
      if (sdkInt >= 30) {
        final manageStatus = await Permission.manageExternalStorage.status;
        if (manageStatus.isGranted) {
          return true;
        }

        // عرض حوار لطلب الإذن
        if (mounted) {
          final shouldRequest = await _showManageStorageDialog();
          if (shouldRequest == true) {
            final result = await Permission.manageExternalStorage.request();
            if (result.isGranted) {
              return true;
            }
          }
        }

        // FilePicker يجب أن يعمل حتى بدون MANAGE_EXTERNAL_STORAGE
        return true;
      }

      // Android 10 وأقل
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        return true;
      }

      final result = await Permission.storage.request();
      return result.isGranted;
    } catch (e) {
      print('خطأ في طلب أذونات التخزين: $e');
      return true; // نحاول المتابعة على أي حال
    }
  }

  /// عرض حوار لطلب إذن إدارة التخزين الخارجي
  Future<bool?> _showManageStorageDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder_open,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'إذن الوصول للتخزين',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لتتمكن من رؤية واختيار ملفات النسخ الاحتياطية، يجب السماح للتطبيق بالوصول إلى جميع الملفات.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'عند الضغط على "السماح"، ستفتح صفحة الإعدادات. قم بتفعيل خيار "السماح بالوصول لإدارة جميع الملفات".',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'لاحقاً',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('السماح', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض قائمة النسخ المحفوظة للاستعادة
  Future<void> _showSavedBackupsDialog() async {
    // تحميل قائمة النسخ
    final backups = await LocalBackupService.instance.listBackups();

    if (!mounted) return;

    if (backups.isEmpty) {
      _showErrorDialog(
        'لا توجد نسخ محفوظة',
        'لا توجد نسخ احتياطية محفوظة في التطبيق.\n\n'
            'يمكنك استخدام خيار "تصفح جميع الملفات" للبحث عن نسخ احتياطية في مكان آخر.',
      );
      return;
    }

    final selectedBackup = await showDialog<BackupMetadata>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.backup,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'اختر نسخة للاستعادة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'اختر النسخة التي تريد استعادتها',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: backups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      final isFirst = index == 0;

                      return InkWell(
                        onTap: () => Navigator.pop(context, backup),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isFirst
                                ? const Color(0xFFF0FDF4)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isFirst
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isFirst
                                      ? const Color(0xFF10B981).withAlpha(25)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.backup,
                                  size: 20,
                                  color: isFirst
                                      ? const Color(0xFF10B981)
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            backup.fileName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isFirst)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF10B981,
                                              ).withAlpha(25),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'الأحدث',
                                              style: TextStyle(
                                                fontSize: 8,
                                                color: Color(0xFF10B981),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${backup.formattedDate} • ${backup.formattedSize}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_left,
                                size: 18,
                                color: isFirst
                                    ? const Color(0xFF10B981)
                                    : Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedBackup == null) return;

    // استعادة النسخة المختارة
    await _restoreSelectedBackup(selectedBackup);
  }

  /// استعادة نسخة محددة
  Future<void> _restoreSelectedBackup(BackupMetadata backup) async {
    // تأكيد الاستعادة
    final confirm = await _showRestoreConfirmDialog(
      fileName: backup.fileName,
      fileSize: backup.formattedSize,
      filePath: backup.filePath,
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      final result = await LocalBackupService.instance.restoreBackup(
        backup.filePath,
      );

      setState(() => _isProcessing = false);

      if (result.success) {
        await _refreshClientsAfterRestore();
        _showRestoreSuccessDialog(
          fileName: backup.fileName,
          fileSize: backup.formattedSize,
          clientsCount: result.clientsCount,
        );

        // تحديث الصفحة
        setState(() {});
      } else {
        _showErrorDialog(
          'فشلت عملية الاستعادة',
          result.errorMessage ?? 'حدث خطأ أثناء استعادة البيانات.',
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorDialog(
        'حدث خطأ غير متوقع',
        'حدث خطأ أثناء محاولة استعادة النسخة الاحتياطية.\n\nالخطأ: ${e.toString()}',
      );
    }
  }

  Future<void> _performLocalRestore() async {
    try {
      String? fileType = await _showFileTypeDialog();
      if (fileType == null) return;

      // إذا اختار المستخدم النسخ المحفوظة، نعرض قائمة النسخ
      if (fileType == 'saved') {
        await _showSavedBackupsDialog();
        return;
      }

      // طلب أذونات التخزين قبل فتح FilePicker
      final hasPermission = await _requestFullStoragePermission();
      if (!hasPermission) {
        _showErrorDialog(
          'أذونات مطلوبة',
          'يجب السماح للتطبيق بالوصول إلى التخزين لاختيار ملفات النسخ الاحتياطية.',
        );
        return;
      }

      setState(() => _isProcessing = true);

      FilePickerResult? result;

      try {
        // استخدام FileType.any دائماً لتجنب مشاكل Android
        // ثم التحقق من الامتداد بعد الاختيار
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
          withData: true,
          withReadStream: false,
        );

        if (result == null || result.files.isEmpty) {
          setState(() => _isProcessing = false);
          return;
        }

        // التحقق من نوع الملف إذا اختار المستخدم db فقط
        if (fileType == 'db') {
          final fileName = result.files.single.name.toLowerCase();
          if (!fileName.endsWith('.db') && !fileName.endsWith('.dbk')) {
            setState(() => _isProcessing = false);
            _showErrorDialog(
              'نوع ملف غير صحيح',
              'الملف المحدد ليس ملف نسخة احتياطية (.db أو .dbk).\n\n'
                  'يرجى اختيار ملف نسخة احتياطية صحيح.',
            );
            return;
          }
        }
      } catch (e) {
        print('خطأ في اختيار الملف: $e');
        setState(() => _isProcessing = false);
        _showErrorDialog(
          'فشل في اختيار الملف',
          'حدث خطأ أثناء محاولة اختيار ملف النسخة الاحتياطية.',
        );
        return;
      }

      final selectedFile = result.files.single;
      String? filePath = selectedFile.path;
      final fileBytes = selectedFile.bytes;

      String? finalFilePath;

      // معالجة الملف
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          finalFilePath = filePath;
        }
      }

      // إذا لم يكن لدينا مسار صالح، نستخدم bytes
      if (finalFilePath == null && fileBytes != null && fileBytes.isNotEmpty) {
        try {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File(
            path.join(
              tempDir.path,
              'restore_${DateTime.now().millisecondsSinceEpoch}.db',
            ),
          );

          await tempFile.writeAsBytes(fileBytes);
          finalFilePath = tempFile.path;
        } catch (e) {
          print('خطأ في حفظ الملف المؤقت: $e');
          setState(() => _isProcessing = false);
          _showErrorDialog(
            'فشل في معالجة الملف',
            'لم نتمكن من الوصول إلى ملف النسخة الاحتياطية.',
          );
          return;
        }
      }

      if (finalFilePath == null || finalFilePath.isEmpty) {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          'ملف غير صالح',
          'لم نتمكن من الوصول إلى ملف النسخة الاحتياطية.',
        );
        return;
      }

      // التحقق من الملف
      final file = File(finalFilePath);
      if (!await file.exists()) {
        setState(() => _isProcessing = false);
        _showErrorDialog(
          'الملف غير موجود',
          'الملف المحدد غير موجود أو تم حذفه.',
        );
        return;
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        setState(() => _isProcessing = false);
        _showErrorDialog('ملف فارغ', 'الملف المحدد فارغ ولا يمكن استعادته.');
        return;
      }

      // تأكيد الاستعادة
      setState(() => _isProcessing = false);

      final confirm = await _showRestoreConfirmDialog(
        fileName: selectedFile.name,
        fileSize: (fileSize / (1024 * 1024)).toStringAsFixed(2),
        filePath: finalFilePath,
      );

      if (confirm != true) {
        // تنظيف الملف المؤقت
        if (finalFilePath.contains('restore_')) {
          try {
            await file.delete();
          } catch (e) {
            debugPrint('فشل حذف الملف المؤقت: $e');
          }
        }
        return;
      }

      setState(() => _isProcessing = true);

      // بدء الاستعادة
      final restoreResult = await LocalBackupService.instance.restoreBackup(
        finalFilePath,
      );

      // تنظيف الملف المؤقت
      if (finalFilePath.contains('restore_')) {
        try {
          final tempFile = File(finalFilePath);
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } catch (e) {
          debugPrint('فشل حذف الملف المؤقت: $e');
        }
      }

      setState(() => _isProcessing = false);

      if (restoreResult.success) {
        await _refreshClientsAfterRestore();
        _showRestoreSuccessDialog(
          fileName: selectedFile.name,
          fileSize: (fileSize / (1024 * 1024)).toStringAsFixed(2),
          clientsCount: restoreResult.clientsCount,
        );
      } else {
        _showErrorDialog(
          'فشلت عملية الاستعادة',
          restoreResult.errorMessage ?? 'حدث خطأ أثناء استعادة البيانات.',
        );
      }
    } catch (e, stackTrace) {
      print('خطأ غير متوقع في الاستعادة: $e');
      print('Stack trace: $stackTrace');

      setState(() => _isProcessing = false);
      _showErrorDialog(
        'حدث خطأ غير متوقع',
        'حدث خطأ أثناء محاولة استعادة النسخة الاحتياطية.\n\nالخطأ: ${e.toString()}',
      );
    }
  }

  Future<String?> _showFileTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.restore, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                'اختر مصدر الاستعادة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر طريقة استعادة النسخة الاحتياطية:',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              // خيار النسخ المحفوظة (الأفضل)
              _buildFileTypeOption(
                context: context,
                icon: Icons.backup,
                title: 'النسخ المحفوظة في التطبيق',
                subtitle: 'اختيار من النسخ المحفوظة تلقائياً',
                value: 'saved',
                highlighted: true,
              ),
              const SizedBox(height: 12),

              // خيار جميع الملفات (يعمل دائماً)
              _buildFileTypeOption(
                context: context,
                icon: Icons.folder_open,
                title: 'تصفح جميع الملفات',
                subtitle: 'البحث يدوياً في ملفات الجهاز',
                value: 'any',
              ),
              const SizedBox(height: 12),

              // خيار ملفات db فقط
              _buildFileTypeOption(
                context: context,
                icon: Icons.insert_drive_file,
                title: 'ملفات قاعدة البيانات (.db)',
                subtitle: 'تصفية حسب نوع الملف',
                value: 'db',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTypeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    bool highlighted = false,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: highlighted
              ? const Color(0xFFEFF6FF)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE5E7EB),
            width: highlighted ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: highlighted
                    ? const Color(0xFF3B82F6).withAlpha(30)
                    : const Color(0xFF5C6EF8).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlighted
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF5C6EF8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: highlighted
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (highlighted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'موصى به',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              size: 18,
              color: highlighted
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showRestoreConfirmDialog({
    required String fileName,
    required String fileSize,
    required String filePath,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'تأكيد الاستعادة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE4B5)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم استبدال جميع البيانات الحالية بالبيانات من النسخة الاحتياطية.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildFileInfoRow(
                Icons.insert_drive_file,
                'اسم الملف:',
                fileName,
              ),
              const SizedBox(height: 8),
              _buildFileInfoRow(Icons.storage, 'حجم الملف:', '$fileSize MB'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(fontSize: 13)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'متابعة الاستعادة',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _performDriveBackup() async {
    // التحقق من الاتصال
    if (!await _checkInternetConnection()) {
      _showErrorDialog(
        'لا يوجد اتصال',
        'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
      );
      return;
    }

    // إذا لم يكن هناك حساب مسجل، نطلب تسجيل الدخول
    if (_driveEmail == null) {
      await _performGoogleSignIn();
      if (_driveEmail == null) return; // فشل تسجيل الدخول
    }

    setState(() {
      _isProcessing = true;
      _processStatus = 'جاري التحضير...';
    });

    try {
      // أولاً: إنشاء نسخة محلية مؤقتة
      setState(() => _processStatus = 'جاري إنشاء ملف مؤقت...');
      final tempResult = await LocalBackupService.instance.createTempBackup();

      if (!tempResult.success || tempResult.filePath == null) {
        _showErrorDialog(
          'فشل إنشاء النسخة',
          tempResult.errorMessage ?? 'حدث خطأ أثناء إنشاء النسخة الاحتياطية',
        );
        return;
      }

      // ثانياً: رفع النسخة إلى Drive
      final uploadResult = await DriveBackupService.instance.uploadBackup(
        tempResult.filePath!,
        onProgress: (status) => setState(() => _processStatus = status),
      );

      if (uploadResult.success) {
        await _loadSettings();
        if (mounted) {
          _showSuccessDialog(
            'تم الرفع بنجاح',
            'تم حفظ النسخة الاحتياطية في Google Drive\n\n${uploadResult.fileName ?? ""}',
          );
        }
      } else {
        _showErrorDialog(
          'فشل الرفع',
          uploadResult.errorMessage ?? 'حدث خطأ أثناء رفع النسخة إلى Drive',
        );
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ', 'خطأ غير متوقع: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
        _processStatus = '';
      });
    }
  }

  Future<void> _performDriveRestore() async {
    // التحقق من الاتصال
    if (!await _checkInternetConnection()) {
      _showErrorDialog(
        'لا يوجد اتصال',
        'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
      );
      return;
    }

    if (_driveEmail == null) {
      await _performGoogleSignIn();
      if (_driveEmail == null) return;
    }

    // عرض قائمة النسخ المتاحة في Drive
    setState(() {
      _isProcessing = true;
      _processStatus = 'جاري البحث عن النسخ...';
    });

    try {
      final backups = await DriveBackupService.instance.listBackups();
      setState(() {
        _isProcessing = false;
        _processStatus = '';
      });

      if (backups.isEmpty) {
        _showErrorDialog(
          'لا توجد نسخ',
          'لا توجد نسخ احتياطية محفوظة في Google Drive',
        );
        return;
      }

      // عرض قائمة النسخ للاختيار
      final selectedBackup = await _showDriveBackupsDialog(backups);
      if (selectedBackup == null) return;

      // تأكيد الاستعادة
      final confirm = await _showConfirmDialog(
        'استعادة من Drive',
        'سيتم استبدال جميع البيانات الحالية بالبيانات من النسخة:\n${selectedBackup.name}\n\nهل تريد المتابعة؟',
      );

      if (confirm != true) return;

      setState(() {
        _isProcessing = true;
        _processStatus = 'جاري التحضير للتنزيل...';
      });

      // تنزيل النسخة
      final downloadedPath = await DriveBackupService.instance.downloadBackup(
        fileId: selectedBackup.id,
        onProgress: (status) => setState(() => _processStatus = status),
      );

      if (downloadedPath == null) {
        _showErrorDialog('فشل التنزيل', 'حدث خطأ أثناء تنزيل النسخة من Drive');
        return;
      }

      setState(() => _processStatus = 'جاري استعادة البيانات...');
      // استعادة النسخة
      final restoreResult = await LocalBackupService.instance.restoreBackup(
        downloadedPath,
      );

      setState(() {
        _isProcessing = false;
        _processStatus = '';
      });

      if (restoreResult.success) {
        await _refreshClientsAfterRestore();
        _showRestoreSuccessDialog(
          fileName: selectedBackup.name,
          fileSize: selectedBackup.formattedSize,
          clientsCount: restoreResult.clientsCount,
        );
      } else {
        _showErrorDialog(
          'فشلت الاستعادة',
          restoreResult.errorMessage ?? 'حدث خطأ أثناء استعادة البيانات',
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processStatus = '';
      });
      _showErrorDialog('حدث خطأ', 'خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// بناء رسالة الخصوصية
  Widget _buildPrivacyNote() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.security, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'نحن نصل فقط للمجلد الخاص بنسخ تطبيق DioMax ولا نرى ملفاتك الأخرى في Google Drive.',
              style: TextStyle(fontSize: 10, color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  /// عرض قائمة النسخ من Drive
  Future<DriveBackupInfo?> _showDriveBackupsDialog(
    List<DriveBackupInfo> backups,
  ) async {
    return showDialog<DriveBackupInfo>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cloud,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'اختر نسخة من Drive',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: backups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final backup = backups[index];
                  final isFirst = index == 0;

                  return InkWell(
                    onTap: () => Navigator.pop(context, backup),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFirst
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_done,
                              size: 18,
                              color: isFirst
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  backup.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${backup.formattedDate} • ${backup.formattedSize}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isFirst)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFDBEAFE),
                                ),
                              ),
                              child: const Text(
                                'الأحدث',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// تسجيل الدخول بـ Google
  Future<void> _performGoogleSignIn() async {
    setState(() => _isProcessing = true);

    try {
      final account = await DriveBackupService.instance.signIn();

      if (account != null) {
        await _loadSettings();
        if (mounted) {
          _showSuccessDialog(
            'تم تسجيل الدخول',
            'مرحباً ${account.displayName ?? account.email}',
          );
        }
      } else {
        _showErrorDialog(
          'فشل تسجيل الدخول',
          'لم يتم تسجيل الدخول. يرجى المحاولة مرة أخرى.',
        );
      }
    } catch (e) {
      _showErrorDialog('خطأ في تسجيل الدخول', e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _selectLocalBackupPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() => _localBackupPath = selectedDirectory);
      await _saveSettings();
    }
  }

  void _showGmailLoginDialog() {
    // استخدام تسجيل الدخول بـ Google مباشرة
    _performGoogleSignIn();
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, height: 1.5),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text('حسناً', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreSuccessDialog({
    required String fileName,
    required String fileSize,
    int? clientsCount,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تمت الاستعادة بنجاح',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  children: [
                    _buildSuccessInfoRow(
                      Icons.insert_drive_file,
                      'الملف:',
                      fileName,
                    ),
                    const SizedBox(height: 8),
                    _buildSuccessInfoRow(
                      Icons.storage,
                      'الحجم:',
                      '$fileSize MB',
                    ),
                    if (clientsCount != null) ...[
                      const SizedBox(height: 8),
                      _buildSuccessInfoRow(
                        Icons.people,
                        'العملاء:',
                        '$clientsCount عميل',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم استرجاع جميع البيانات بنجاح. يمكنك الآن استخدام التطبيق.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('حسناً', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF10B981)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF065F46),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14)),
          content: Text(message, style: const TextStyle(fontSize: 12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('متابعة', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFrequencyDialog(bool isLocal) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'تكرار النسخ الاحتياطي',
            style: TextStyle(fontSize: 14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final freq in ['يومياً', 'أسبوعياً', 'شهرياً'])
                RadioListTile<String>(
                  title: Text(freq, style: const TextStyle(fontSize: 12)),
                  value: freq,
                  groupValue: isLocal ? _localFrequency : _driveFrequency,
                  onChanged: (value) => Navigator.pop(context, value),
                  dense: true,
                ),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isLocal) {
          _localFrequency = result;
        } else {
          _driveFrequency = result;
        }
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                'النسخ الاحتياطي',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم Gmail
                  if (_driveEmail != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade50, Colors.red.shade100],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.email,
                              color: Colors.red.shade600,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _driveEmail!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_lastDriveBackup != null)
                                  Text(
                                    'آخر نسخة: $_lastDriveBackup',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.logout,
                              size: 14,
                              color: Colors.red.shade600,
                            ),
                            onPressed: () async {
                              await DriveBackupService.instance.unlinkAccount();
                              await _loadSettings();
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // قسم النسخ المحلي
                  _buildSectionTitle(Icons.phone_android, 'النسخ المحلي'),
                  const SizedBox(height: 8),

                  BackupActionButton(
                    icon: Icons.save_alt,
                    title: 'نسخ احتياطي محلي',
                    subtitle: 'حفظ على الجهاز',
                    color: const Color(0xFF3B82F6),
                    onTap: _performLocalBackup,
                    isLoading: _isProcessing,
                  ),
                  const SizedBox(height: 8),
                  BackupActionButton(
                    icon: Icons.restore,
                    title: 'استعادة محلية',
                    subtitle: 'من ملف على الجهاز',
                    color: const Color(0xFFF59E0B),
                    onTap: _performLocalRestore,
                    isLoading: _isProcessing,
                  ),

                  const SizedBox(height: 14),

                  // قائمة النسخ المحفوظة
                  BackupListWidget(
                    key: _backupListKey,
                    onRestoreComplete: () {
                      _refreshClientsAfterRestore();
                      setState(() {});
                    },
                    onBackupDeleted: () {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 10),
                  _buildOptionsCard(
                    children: [
                      _buildOptionRow(
                        icon: Icons.sync,
                        title: 'نسخ تلقائي',
                        trailing: Switch(
                          value: _localAutoBackup,
                          onChanged: (value) async {
                            if (value) {
                              await BackgroundBackupService.requestNotificationPermission();
                            }
                            setState(() => _localAutoBackup = value);
                            await _saveSettings();
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                      if (_localAutoBackup) ...[
                        const Divider(height: 1),
                        _buildOptionRow(
                          icon: Icons.schedule,
                          title: 'التكرار',
                          subtitle: _localFrequency,
                          onTap: () => _showFrequencyDialog(true),
                        ),
                        const Divider(height: 1),
                        _buildOptionRow(
                          icon: Icons.access_time, // icon for time
                          title: 'وقت النسخ',
                          subtitle: _localBackupTime.format(context),
                          onTap: () => _selectTime(true),
                        ),
                      ],
                      const Divider(height: 1),
                      _buildOptionRow(
                        icon: Icons.folder,
                        title: 'موقع الحفظ',
                        subtitle: _localBackupPath.split('/').last,
                        onTap: _selectLocalBackupPath,
                      ),
                      const Divider(height: 1),
                      _buildOptionRow(
                        icon: Icons.timer,
                        title: 'تجربة سريعة (30 ثانية)',
                        subtitle: 'اختبار فوري لنظام النسخ الجديد',
                        onTap: () async {
                          await BackgroundBackupService.runQuickTest();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تمت الجدولة! انتظر 30 ثانية للإشعار',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // قسم Google Drive
                  _buildSectionTitle(Icons.cloud, 'Google Drive'),
                  const SizedBox(height: 8),

                  BackupActionButton(
                    icon: Icons.cloud_upload,
                    title: 'نسخ احتياطي - Drive',
                    subtitle: _driveEmail == null
                        ? 'سجل دخول أولاً'
                        : 'رفع إلى Drive',
                    color: const Color(0xFF10B981),
                    onTap: _performDriveBackup,
                    isLoading: _isProcessing,
                  ),
                  const SizedBox(height: 8),
                  BackupActionButton(
                    icon: Icons.cloud_download,
                    title: 'استعادة من Drive',
                    subtitle: _driveEmail == null
                        ? 'سجل دخول أولاً'
                        : 'تنزيل آخر نسخة',
                    color: const Color(0xFF8B5CF6),
                    onTap: _performDriveRestore,
                    isLoading: _isProcessing,
                  ),

                  // ملاحظة الخصوصية الجديدة
                  _buildPrivacyNote(),

                  const SizedBox(height: 10),
                  _buildOptionsCard(
                    children: [
                      if (_driveEmail == null)
                        _buildOptionRow(
                          icon: Icons.login,
                          title: 'تسجيل الدخول',
                          subtitle: 'مطلوب للنسخ الاحتياطي',
                          onTap: _showGmailLoginDialog,
                        ),

                      if (_driveEmail != null) ...[
                        _buildOptionRow(
                          icon: Icons.sync,
                          title: 'نسخ تلقائي',
                          trailing: Switch(
                            value: _driveAutoBackup,
                            onChanged: (value) async {
                              if (value) {
                                await BackgroundBackupService.requestNotificationPermission();
                              }
                              setState(() => _driveAutoBackup = value);
                              await _saveSettings();
                            },
                            activeColor: Colors.green,
                          ),
                        ),
                        if (_driveAutoBackup) ...[
                          const Divider(height: 1),
                          _buildOptionRow(
                            icon: Icons.schedule,
                            title: 'التكرار',
                            subtitle: _driveFrequency,
                            onTap: () => _showFrequencyDialog(false),
                          ),
                          const Divider(height: 1),
                          _buildOptionRow(
                            icon: Icons.access_time,
                            title: 'وقت النسخ',
                            subtitle: _driveBackupTime.format(context),
                            onTap: () => _selectTime(false),
                          ),
                        ],
                      ],
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ملاحظة
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'جميع النسخ الاحتياطية مشفرة تلقائياً لحماية بياناتك',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // طبقة التحميل (Overlay)
          // طبقة التحميل (Overlay)
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5), // خلفية شبه شفافة داكنة
              child: Center(
                child: Material(
                  color: Colors.white,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _processStatus.isEmpty
                              ? 'جاري العمل...'
                              : _processStatus,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151), // لون رمادي داكن
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 14,
                color: iconColor ?? Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_left, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
