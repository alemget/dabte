import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../../data/debt_database.dart';
import '../../../../utils/encryption_helper.dart';
import '../models/backup_metadata.dart';
import 'backup_file_manager.dart';

/// خدمة النسخ الاحتياطي المحلي المحسّنة
/// تدعم جميع إصدارات Android وتوفر تجربة مستخدم أفضل
class LocalBackupService {
  static final LocalBackupService instance = LocalBackupService._internal();
  LocalBackupService._internal();

  // مفتاح التطبيق الثابت للتشفير
  static const String _appSecretKey = 'DebtManager_2025_SecureKey_v1';


  final BackupFileManager _fileManager = BackupFileManager.instance;

  /// إنشاء نسخة احتياطية محلية
  Future<BackupResult> createBackup([String? customPath]) async {
    try {
      debugPrint('بدء إنشاء النسخة الاحتياطية...');
      
      // الحصول على قاعدة البيانات
      final db = await DebtDatabase.instance.database;
      final dbPath = db.path;
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        return BackupResult(
          success: false,
          errorMessage: 'قاعدة البيانات غير موجودة',
        );
      }

      // الحصول على مسار النسخة الاحتياطية
      String backupPath;
      if (customPath != null && customPath.isNotEmpty) {
        final fileName = _fileManager.generateBackupFileName();
        backupPath = path.join(customPath, fileName);
        
        // التأكد من وجود المجلد
        final dir = Directory(customPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } else {
        backupPath = await _fileManager.getNewBackupPath();
      }

      debugPrint('مسار النسخة الاحتياطية: $backupPath');

      final backupFile = File(backupPath);

      // إنشاء نسخة مع التشفير
      await EncryptionHelper.encryptFile(dbFile, backupFile, _appSecretKey);

      // التحقق من نجاح الإنشاء
      if (!await backupFile.exists()) {
        return BackupResult(
          success: false,
          errorMessage: 'فشل في إنشاء ملف النسخة الاحتياطية',
        );
      }

      final fileSize = await backupFile.length();
      
      // الحصول على إحصائيات قاعدة البيانات
      int clientsCount = 0;
      int transactionsCount = 0;
      try {
        final clients = await DebtDatabase.instance.getClients();
        clientsCount = clients.length;
        // يمكن إضافة حساب المعاملات لاحقاً
      } catch (e) {
        debugPrint('تحذير: لم نتمكن من الحصول على إحصائيات: $e');
      }

      final metadata = BackupMetadata(
        fileName: path.basename(backupPath),
        filePath: backupPath,
        createdAt: DateTime.now(),
        fileSizeBytes: fileSize,
        clientsCount: clientsCount,
        transactionsCount: transactionsCount,
        format: BackupFormat.v2,
        isEncrypted: true,
      );

      debugPrint('تم إنشاء النسخة الاحتياطية بنجاح: ${metadata.fileName}');
      
      // نسخ الملف إلى مجلد Downloads ليكون مرئياً للمستخدم
      try {
        final downloadsPath = await _fileManager.copyBackupToDownloads(backupPath);
        if (downloadsPath != null) {
          debugPrint('تم نسخ النسخة الاحتياطية إلى Downloads: $downloadsPath');
        }
      } catch (e) {
        debugPrint('تحذير: لم نتمكن من نسخ الملف إلى Downloads: $e');
        // نستمر بدون إظهار خطأ للمستخدم
      }
      
      return BackupResult(
        success: true,
        filePath: backupPath,
        metadata: metadata,
      );

    } catch (e, stackTrace) {
      debugPrint('خطأ في إنشاء النسخة الاحتياطية: $e');
      debugPrint('Stack trace: $stackTrace');
      return BackupResult(
        success: false,
        errorMessage: 'حدث خطأ أثناء إنشاء النسخة الاحتياطية: ${e.toString()}',
      );
    }
  }

  /// إنشاء نسخة احتياطية مؤقتة للرفع إلى Drive
  Future<BackupResult> createTempBackup() async {
    try {
      debugPrint('بدء إنشاء نسخة احتياطية مؤقتة...');
      
      // الحصول على قاعدة البيانات
      final db = await DebtDatabase.instance.database;
      final dbPath = db.path;
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        return BackupResult(
          success: false,
          errorMessage: 'قاعدة البيانات غير موجودة',
        );
      }

      // إنشاء ملف مؤقت
      final tempDir = await getTemporaryDirectory();
      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.db';
      final tempBackupPath = path.join(tempDir.path, fileName);

      debugPrint('مسار النسخة المؤقتة: $tempBackupPath');

      final backupFile = File(tempBackupPath);

      // إنشاء نسخة مع التشفير
      await EncryptionHelper.encryptFile(dbFile, backupFile, _appSecretKey);

      // التحقق من نجاح الإنشاء
      if (!await backupFile.exists()) {
        return BackupResult(
          success: false,
          errorMessage: 'فشل في إنشاء ملف النسخة الاحتياطية المؤقتة',
        );
      }

      final fileSize = await backupFile.length();

      final metadata = BackupMetadata(
        fileName: fileName,
        filePath: tempBackupPath,
        createdAt: DateTime.now(),
        fileSizeBytes: fileSize,
        clientsCount: 0,
        transactionsCount: 0,
        format: BackupFormat.v2,
        isEncrypted: true,
      );

      debugPrint('تم إنشاء النسخة المؤقتة بنجاح: $fileName');
      
      return BackupResult(
        success: true,
        filePath: tempBackupPath,
        metadata: metadata,
      );

    } catch (e, stackTrace) {
      debugPrint('خطأ في إنشاء النسخة المؤقتة: $e');
      debugPrint('Stack trace: $stackTrace');
      return BackupResult(
        success: false,
        errorMessage: 'حدث خطأ أثناء إنشاء النسخة المؤقتة: ${e.toString()}',
      );
    }
  }

  /// إنشاء نسخة احتياطية تلقائية (للاستخدام في الخلفية)
  Future<BackupResult> createAutoBackup() async {
    try {
      // محاولة الحصول على المسار المحفوظ في التفضيلات
      // ملاحظة: لا يمكننا الوصول لـ SharedPreferences هنا بسهولة إذا لم يتم تمريرها
      // لكن يمكننا استخدام path_provider للحصول على المسار الافتراضي
      
      // سنستخدم createBackup الافتراضية التي تقوم بكل شيء
      // يمكن تحسينها لاحقاً لقراءة المسار من التفضيلات إذا لزم الأمر
      // (createBackup تقرأ المسار الافتراضي إذا لم يتم تمرير مسار)
      
      return await createBackup();
    } catch (e) {
      return BackupResult(
        success: false,
        errorMessage: 'فشل النسخ التلقائي: $e',
      );
    }
  }

  /// إنشاء نسخة احتياطية باسم ومسار محددين
  Future<BackupResult> createBackupWithName(String destinationPath, String fileName) async {
    try {
      debugPrint('بدء إنشاء النسخة الاحتياطية...');
      debugPrint('المسار: $destinationPath');
      debugPrint('اسم الملف: $fileName');
      
      // الحصول على قاعدة البيانات
      final db = await DebtDatabase.instance.database;
      final dbPath = db.path;
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        return BackupResult(
          success: false,
          errorMessage: 'قاعدة البيانات غير موجودة',
        );
      }

      // التأكد من وجود المجلد
      final dir = Directory(destinationPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // إنشاء مسار الملف الكامل
      final backupPath = path.join(destinationPath, fileName);
      debugPrint('مسار النسخة الاحتياطية الكامل: $backupPath');

      final backupFile = File(backupPath);

      // إنشاء نسخة مع التشفير
      await EncryptionHelper.encryptFile(dbFile, backupFile, _appSecretKey);

      // التحقق من نجاح الإنشاء
      if (!await backupFile.exists()) {
        return BackupResult(
          success: false,
          errorMessage: 'فشل في إنشاء ملف النسخة الاحتياطية',
        );
      }

      final fileSize = await backupFile.length();
      
      // الحصول على إحصائيات قاعدة البيانات
      int clientsCount = 0;
      int transactionsCount = 0;
      try {
        final clients = await DebtDatabase.instance.getClients();
        clientsCount = clients.length;
      } catch (e) {
        debugPrint('تحذير: لم نتمكن من الحصول على إحصائيات: $e');
      }

      final metadata = BackupMetadata(
        fileName: fileName,
        filePath: backupPath,
        createdAt: DateTime.now(),
        fileSizeBytes: fileSize,
        clientsCount: clientsCount,
        transactionsCount: transactionsCount,
        format: BackupFormat.v2,
        isEncrypted: true,
      );

      debugPrint('تم إنشاء النسخة الاحتياطية بنجاح: ${metadata.fileName}');
      
      // نسخ الملف إلى مجلد Downloads ليكون مرئياً للمستخدم
      try {
        final downloadsPath = await _fileManager.copyBackupToDownloads(backupPath);
        if (downloadsPath != null) {
          debugPrint('تم نسخ النسخة الاحتياطية إلى Downloads: $downloadsPath');
        }
      } catch (e) {
        debugPrint('تحذير: لم نتمكن من نسخ الملف إلى Downloads: $e');
      }
      
      return BackupResult(
        success: true,
        filePath: backupPath,
        metadata: metadata,
      );

    } catch (e, stackTrace) {
      debugPrint('خطأ في إنشاء النسخة الاحتياطية: $e');
      debugPrint('Stack trace: $stackTrace');
      return BackupResult(
        success: false,
        errorMessage: 'حدث خطأ أثناء إنشاء النسخة الاحتياطية: ${e.toString()}',
      );
    }
  }

  /// استعادة نسخة احتياطية
  Future<RestoreResult> restoreBackup(String backupFilePath) async {
    try {
      debugPrint('بدء استعادة النسخة الاحتياطية من: $backupFilePath');
      
      final backupFile = File(backupFilePath);
      
      // التحقق من وجود الملف
      if (!await backupFile.exists()) {
        return RestoreResult(
          success: false,
          errorMessage: 'ملف النسخة الاحتياطية غير موجود في المسار المحدد.',
        );
      }

      // التحقق من حجم الملف
      final fileSize = await backupFile.length();
      if (fileSize == 0) {
        return RestoreResult(
          success: false,
          errorMessage: 'الملف فارغ ولا يمكن استعادته.',
        );
      }

      if (fileSize < 1024) {
        return RestoreResult(
          success: false,
          errorMessage: 'الملف صغير جداً وقد يكون تالفاً.',
        );
      }

      debugPrint('حجم الملف: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // الحصول على مسار قاعدة البيانات
      final db = await DebtDatabase.instance.database;
      final dbPath = db.path;
      
      debugPrint('مسار قاعدة البيانات: $dbPath');

      // إنشاء نسخة احتياطية من قاعدة البيانات الحالية قبل الاستعادة
      await _createPreRestoreBackup(dbPath);

      // إغلاق قاعدة البيانات
      await DebtDatabase.instance.resetDatabase();
      debugPrint('تم إغلاق قاعدة البيانات');

      final dbFile = File(dbPath);

      // فك التشفير والاستعادة
      debugPrint('بدء فك التشفير والاستعادة...');
      
      try {
        await EncryptionHelper.decryptFile(backupFile, dbFile, _appSecretKey);
        debugPrint('تم فك التشفير بنجاح');
      } catch (e) {
        debugPrint('خطأ في فك التشفير: $e');
        
        // محاولة نسخ الملف مباشرة (للنسخ غير المشفرة)
        try {
          await backupFile.copy(dbPath);
          debugPrint('تم نسخ الملف مباشرة');
        } catch (copyError) {
          return RestoreResult(
            success: false,
            errorMessage: 'فشل فك التشفير والنسخ المباشر.\n\n'
                'تأكد من أن الملف هو نسخة احتياطية صحيحة من هذا التطبيق.',
          );
        }
      }

      // التحقق من أن الملف المستعاد موجود وصحيح
      if (!await dbFile.exists()) {
        return RestoreResult(
          success: false,
          errorMessage: 'فشل في إنشاء قاعدة البيانات المستعادة.',
        );
      }

      final restoredFileSize = await dbFile.length();
      if (restoredFileSize == 0) {
        return RestoreResult(
          success: false,
          errorMessage: 'قاعدة البيانات المستعادة فارغة.',
        );
      }

      debugPrint('حجم قاعدة البيانات المستعادة: ${(restoredFileSize / 1024).toStringAsFixed(2)} KB');


      // إعادة فتح قاعدة البيانات للتحقق من صحتها
      try {
        // إعادة فتح قاعدة البيانات
        await DebtDatabase.instance.database;
        
        // محاولة قراءة بسيطة للتحقق من صحة قاعدة البيانات
        final clients = await DebtDatabase.instance.getClients();
        debugPrint('تم التحقق من قاعدة البيانات: ${clients.length} عميل موجود');

        return RestoreResult(
          success: true,
          clientsCount: clients.length,
        );
      } catch (e) {
        debugPrint('خطأ في التحقق من قاعدة البيانات المستعادة: $e');
        return RestoreResult(
          success: false,
          errorMessage: 'قاعدة البيانات المستعادة تالفة أو غير صحيحة.\n\n'
                       'الخطأ: ${e.toString()}',
        );
      }

    } catch (e, stackTrace) {
      debugPrint('خطأ في الاستعادة: $e');
      debugPrint('Stack trace: $stackTrace');
      
      String errorMessage = 'حدث خطأ أثناء استعادة النسخة الاحتياطية.';
      
      if (e.toString().contains('decrypt') || e.toString().contains('تشفير')) {
        errorMessage = 'فشل فك التشفير.\n\n'
                      'تأكد من أن الملف هو نسخة احتياطية صحيحة من هذا التطبيق.';
      } else if (e.toString().contains('permission') || e.toString().contains('أذونات')) {
        errorMessage = 'لا توجد أذونات كافية للوصول إلى الملف.\n\n'
                      'يرجى التحقق من أذونات التطبيق.';
      } else if (e.toString().contains('space') || e.toString().contains('مساحة')) {
        errorMessage = 'لا توجد مساحة كافية على الجهاز.\n\n'
                      'يرجى تحرير بعض المساحة والمحاولة مرة أخرى.';
      } else {
        errorMessage = 'حدث خطأ غير متوقع.\n\n'
                      'الخطأ: ${e.toString()}';
      }
      
      return RestoreResult(
        success: false,
        errorMessage: errorMessage,
      );
    }
  }

  /// إنشاء نسخة احتياطية قبل الاستعادة
  Future<void> _createPreRestoreBackup(String dbPath) async {
    try {
      final backupDir = Directory(path.dirname(dbPath));
      final currentBackupPath = path.join(
        backupDir.path,
        'pre_restore_backup_${DateTime.now().millisecondsSinceEpoch}.db',
      );
      final currentDbFile = File(dbPath);
      if (await currentDbFile.exists()) {
        await currentDbFile.copy(currentBackupPath);
        debugPrint('تم إنشاء نسخة احتياطية من البيانات الحالية: $currentBackupPath');
      }
    } catch (e) {
      debugPrint('تحذير: لم نتمكن من إنشاء نسخة احتياطية من البيانات الحالية: $e');
    }
  }

  /// الحصول على قائمة النسخ الاحتياطية
  Future<List<BackupMetadata>> listBackups() async {
    return await _fileManager.listBackups();
  }

  /// حذف نسخة احتياطية
  Future<bool> deleteBackup(String filePath) async {
    return await _fileManager.deleteBackup(filePath);
  }

  /// الحصول على المسار الافتراضي
  Future<String> getDefaultBackupPath() async {
    final backupDir = await _fileManager.getBackupDirectory();
    return backupDir.path;
  }

  /// تنظيف النسخ القديمة
  Future<int> cleanupOldBackups({int keepCount = 5}) async {
    return await _fileManager.cleanupOldBackups(keepCount: keepCount);
  }

  /// حساب checksum للملف
  Future<String> calculateChecksum(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = md5.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  /// التحقق من صحة نسخة احتياطية
  Future<bool> validateBackup(String filePath) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        return false;
      }

      final size = await file.length();
      if (size < 1024) {
        return false;
      }

      // محاولة قراءة البداية للتحقق من التنسيق
      // يمكن إضافة المزيد من التحققات لاحقاً

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// نتيجة النسخ الاحتياطي
class BackupResult {
  final bool success;
  final String? filePath;
  final String? errorMessage;
  final BackupMetadata? metadata;

  BackupResult({
    required this.success,
    this.filePath,
    this.errorMessage,
    this.metadata,
  });
}

/// نتيجة الاستعادة
class RestoreResult {
  final bool success;
  final String? errorMessage;
  final int? clientsCount;

  RestoreResult({
    required this.success,
    this.errorMessage,
    this.clientsCount,
  });
}
