import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../domain/entities/backup_metadata.dart';

/// مدير ملفات النسخ الاحتياطي
/// يتعامل مع حفظ وقراءة الملفات بطريقة متوافقة مع جميع إصدارات Android
class BackupFileManager {
  static final BackupFileManager instance = BackupFileManager._internal();
  BackupFileManager._internal();

  static const String _backupFolderName = 'DebtMaxBackups';
  static const String _backupPrefix = 'backup_';
  static const String _backupExtension = '.db';

  // قناة للتواصل مع Android native code
  static const MethodChannel _channel = MethodChannel('debtmax/backup');

  /// الحصول على إصدار Android SDK
  Future<int> getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (e) {
      debugPrint('خطأ في الحصول على إصدار Android: $e');
      return 28; // افتراضي
    }
  }

  /// الحصول على مجلد النسخ الاحتياطي الافتراضي (داخل مجلد التطبيق)
  Future<Directory> getBackupDirectory() async {
    try {
      if (Platform.isAndroid) {
        final sdkVersion = await getAndroidSdkVersion();

        // Android 10+ (API 29+): استخدام مجلد التطبيق الخارجي
        if (sdkVersion >= 29) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final backupDir = Directory(path.join(externalDir.path, _backupFolderName));
            if (!await backupDir.exists()) {
              await backupDir.create(recursive: true);
            }
            return backupDir;
          }
        }

        // Android 9 وأقل: يمكن استخدام التخزين الخارجي
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final backupDir = Directory(path.join(externalDir.path, _backupFolderName));
          if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
          }
          return backupDir;
        }
      }

      // Fallback: مجلد المستندات
      final documentsDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(documentsDir.path, _backupFolderName));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      return backupDir;
    } catch (e) {
      debugPrint('خطأ في الحصول على مجلد النسخ: $e');
      final documentsDir = await getApplicationDocumentsDirectory();
      return Directory(path.join(documentsDir.path, _backupFolderName));
    }
  }

  /// الحصول على مجلد Downloads للنسخ الاحتياطية (مرئي للمستخدم)
  Future<Directory?> getDownloadsBackupDirectory() async {
    try {
      if (Platform.isAndroid) {
        // مسار مجلد Downloads على Android
        const downloadsPath = '/storage/emulated/0/Download';
        final backupDir = Directory(path.join(downloadsPath, _backupFolderName));

        try {
          if (!await backupDir.exists()) {
            await backupDir.create(recursive: true);
          }
          return backupDir;
        } catch (e) {
          debugPrint('لا يمكن إنشاء مجلد في Downloads: $e');
          // محاولة بديلة: استخدام مجلد Documents
          final docsDir = await getExternalStorageDirectory();
          if (docsDir != null) {
            // الصعود للمسار الجذري والنزول لـ Download
            final parts = docsDir.path.split('/');
            final baseIndex = parts.indexOf('Android');
            if (baseIndex > 0) {
              final basePath = parts.sublist(0, baseIndex).join('/');
              final altDownloadsDir = Directory(path.join(basePath, 'Download', _backupFolderName));
              try {
                if (!await altDownloadsDir.exists()) {
                  await altDownloadsDir.create(recursive: true);
                }
                return altDownloadsDir;
              } catch (e2) {
                debugPrint('فشل البديل أيضاً: $e2');
              }
            }
          }
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('خطأ في الحصول على مجلد Downloads: $e');
      return null;
    }
  }

  /// نسخ ملف نسخة احتياطية إلى مجلد Downloads
  Future<String?> copyBackupToDownloads(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('الملف المصدر غير موجود: $sourcePath');
        return null;
      }

      final downloadsDir = await getDownloadsBackupDirectory();
      if (downloadsDir == null) {
        debugPrint('لا يمكن الوصول إلى مجلد Downloads');
        return null;
      }

      final fileName = path.basename(sourcePath);
      final destPath = path.join(downloadsDir.path, fileName);

      await sourceFile.copy(destPath);
      debugPrint('تم نسخ الملف إلى: $destPath');
      return destPath;
    } catch (e) {
      debugPrint('خطأ في نسخ الملف إلى Downloads: $e');
      return null;
    }
  }

  /// الحصول على مسار مجلد Downloads للنسخ الاحتياطية
  Future<String> getDownloadsPath() async {
    final dir = await getDownloadsBackupDirectory();
    if (dir != null) {
      return dir.path;
    }
    // Fallback
    return '/storage/emulated/0/Download/$_backupFolderName';
  }

  /// إنشاء اسم ملف نسخة احتياطية جديدة
  String generateBackupFileName() {
    final now = DateTime.now();
    return '$_backupPrefix'
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '$_backupExtension';
  }

  /// الحصول على قائمة النسخ الاحتياطية المتاحة
  Future<List<BackupMetadata>> listBackups() async {
    final List<BackupMetadata> backups = [];

    try {
      // البحث في مجلد التطبيق
      final backupDir = await getBackupDirectory();
      if (await backupDir.exists()) {
        final files = await backupDir.list().toList();

        for (final entity in files) {
          if (entity is File) {
            final fileName = path.basename(entity.path);
            if (_isBackupFile(fileName)) {
              try {
                final stat = await entity.stat();
                backups.add(BackupMetadata.fromFile(
                  fileName: fileName,
                  filePath: entity.path,
                  fileSize: stat.size,
                  createdAt: stat.modified,
                ));
              } catch (e) {
                debugPrint('خطأ في قراءة معلومات الملف: $e');
              }
            }
          }
        }
      }

      // البحث في مجلد Documents أيضاً
      final documentsDir = await getApplicationDocumentsDirectory();
      final docsBackupDir = Directory(path.join(documentsDir.path, _backupFolderName));
      if (await docsBackupDir.exists() && docsBackupDir.path != backupDir.path) {
        final files = await docsBackupDir.list().toList();

        for (final entity in files) {
          if (entity is File) {
            final fileName = path.basename(entity.path);
            if (_isBackupFile(fileName)) {
              try {
                final stat = await entity.stat();
                // تجنب التكرار
                if (!backups.any((b) => b.fileName == fileName)) {
                  backups.add(BackupMetadata.fromFile(
                    fileName: fileName,
                    filePath: entity.path,
                    fileSize: stat.size,
                    createdAt: stat.modified,
                  ));
                }
              } catch (e) {
                print('خطأ في قراءة معلومات الملف: $e');
              }
            }
          }
        }
      }

      // ترتيب حسب التاريخ (الأحدث أولاً)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('خطأ في قراءة قائمة النسخ الاحتياطية: $e');
    }

    return backups;
  }

  /// التحقق من أن الملف هو نسخة احتياطية
  bool _isBackupFile(String fileName) {
    return fileName.startsWith(_backupPrefix) && (fileName.endsWith('.db') || fileName.endsWith('.dbk'));
  }

  /// حذف نسخة احتياطية
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في حذف النسخة الاحتياطية: $e');
      return false;
    }
  }

  /// نسخ ملف إلى مجلد Downloads (للمشاركة)
  Future<String?> copyToDownloads(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return null;
      }

      final fileName = path.basename(sourcePath);

      if (Platform.isAndroid) {
        final sdkVersion = await getAndroidSdkVersion();

        // Android 10+: نحاول نسخ إلى مجلد خارجي يمكن الوصول إليه
        if (sdkVersion >= 29) {
          // استخدام مجلد التطبيق الخارجي (يمكن الوصول إليه من مدير الملفات)
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // الصعود للمجلد الرئيسي للتطبيق
            final appDir = externalDir.parent.parent.parent.parent;
            final downloadsPath = path.join(appDir.path, 'Download', _backupFolderName);
            final downloadsDir = Directory(downloadsPath);

            try {
              if (!await downloadsDir.exists()) {
                await downloadsDir.create(recursive: true);
              }

              final destPath = path.join(downloadsPath, fileName);
              await sourceFile.copy(destPath);
              return destPath;
            } catch (e) {
              // إذا فشل، نبقى في مجلد التطبيق
              debugPrint('لم نتمكن من النسخ إلى Downloads: $e');
              return sourcePath;
            }
          }
        }
      }

      return sourcePath;
    } catch (e) {
      debugPrint('خطأ في نسخ الملف: $e');
      return null;
    }
  }

  /// الحصول على مسار الملف الكامل لنسخة جديدة
  Future<String> getNewBackupPath() async {
    final backupDir = await getBackupDirectory();
    final fileName = generateBackupFileName();
    return path.join(backupDir.path, fileName);
  }

  /// تنظيف النسخ القديمة (الاحتفاظ بعدد محدد)
  Future<int> cleanupOldBackups({int keepCount = 5}) async {
    try {
      final backups = await listBackups();

      if (backups.length <= keepCount) {
        return 0;
      }

      int deletedCount = 0;
      // حذف النسخ القديمة (القائمة مرتبة من الأحدث للأقدم)
      for (int i = keepCount; i < backups.length; i++) {
        if (await deleteBackup(backups[i].filePath)) {
          deletedCount++;
        }
      }

      return deletedCount;
    } catch (e) {
      debugPrint('خطأ في تنظيف النسخ القديمة: $e');
      return 0;
    }
  }

  /// الحصول على إجمالي حجم النسخ الاحتياطية
  Future<int> getTotalBackupsSize() async {
    try {
      final backups = await listBackups();
      int totalSize = 0;
      for (final backup in backups) {
        totalSize += backup.fileSizeBytes;
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// تنسيق الحجم
  String formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
