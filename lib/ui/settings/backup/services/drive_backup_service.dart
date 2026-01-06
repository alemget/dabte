export 'package:dabdt/features/backup/data/datasources/drive_backup_service.dart';

/*
/// خدمة النسخ الاحتياطي عبر Google Drive
class DriveBackupService {
  static final DriveBackupService instance = DriveBackupService._internal();
  DriveBackupService._internal();

  static const String _emailKey = 'drive_email';
  static const String _lastBackupKey = 'drive_last_backup';
  static const String _backupFolderName = 'DioMaxBackups';
  
  // Google Sign-In مع صلاحيات Drive
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive.DriveApi.driveFileScope, // صلاحية الوصول للملفات التي أنشأها التطبيق فقط
    ],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;
  drive.DriveApi? _driveApi;

  /// الحصول على البريد الإلكتروني المرتبط
  Future<String?> getLinkedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
 

  /// حفظ البريد الإلكتروني
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// إزالة الربط
  Future<void> unlinkAccount() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      _currentUser = null;
      _driveApi = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_emailKey);
      await prefs.remove(_lastBackupKey);
    } catch (e) {
      debugPrint('خطأ في إلغاء الربط: $e');
    }
  }

  /// الحصول على تاريخ آخر نسخة احتياطية
  Future<String?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBackupKey);
  }

  /// التحقق من الربط
  Future<bool> isLinked() async {
    final email = await getLinkedEmail();
    return email != null && email.isNotEmpty;
  }

  /// تسجيل الدخول بـ Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // محاولة تسجيل الدخول الصامت أولاً
      _currentUser = await _googleSignIn.signInSilently();
      
      // إذا فشل، نطلب تسجيل دخول تفاعلي
      _currentUser ??= await _googleSignIn.signIn();
      
      if (_currentUser != null) {
        await saveEmail(_currentUser!.email);
        await _initializeDriveApi();
      }
      
      return _currentUser;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      if (e.toString().contains('network_error')) {
        throw 'خطأ في الشبكة، يرجى التحقق من اتصال الإنترنت';
      }
      return null;
    }
  }

  /// تهيئة Drive API
  Future<void> _initializeDriveApi() async {
    if (_currentUser == null) return;
    
    try {
      final googleAuth = await _currentUser!.authentication;
      
      final authClient = GoogleAuthClient({
        'Authorization': 'Bearer ${googleAuth.accessToken}',
      });
      
      _driveApi = drive.DriveApi(authClient);
    } catch (e) {
      debugPrint('خطأ في تهيئة Drive API: $e');
    }
  }

  /// التحقق من تسجيل الدخول وتهيئة API
  Future<bool> ensureSignedIn() async {
    if (_currentUser == null) {
      try {
        _currentUser = await _googleSignIn.signInSilently();
      } catch (e) {
        debugPrint('خطأ في استعادة تسجيل الدخول: $e');
      }
    }
    
    if (_currentUser == null) {
      return false;
    }
    
    if (_driveApi == null) {
      await _initializeDriveApi();
    }
    
    return _driveApi != null;
  }

  /// الحصول على أو إنشاء مجلد النسخ الاحتياطية
  Future<String?> _getOrCreateBackupFolder() async {
    if (_driveApi == null) return null;
    
    try {
      // البحث عن المجلد
      final response = await _driveApi!.files.list(
        q: "name='$_backupFolderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );
      
      if (response.files != null && response.files!.isNotEmpty) {
        return response.files!.first.id;
      }
      
      // إنشاء مجلد جديد
      final folder = drive.File()
        ..name = _backupFolderName
        ..mimeType = 'application/vnd.google-apps.folder';
      
      final createdFolder = await _driveApi!.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      debugPrint('خطأ في الحصول على مجلد النسخ: $e');
      throw _mapDriveError(e);
    }
  }

  /// رفع نسخة احتياطية إلى Drive
  Future<DriveBackupResult> uploadBackup(String filePath, {Function(String)? onProgress}) async {
    try {
      onProgress?.call('جاري التحقق من تسجيل الدخول...');
      // التحقق من تسجيل الدخول
      if (!await ensureSignedIn()) {
        return DriveBackupResult(
          success: false,
          errorMessage: 'الرجاء تسجيل الدخول أولاً للمتابعة',
        );
      }
      
      // التحقق من وجود الملف
      final file = File(filePath);
      if (!await file.exists()) {
        return DriveBackupResult(
          success: false,
          errorMessage: 'لم يتم العثور على ملف النسخة الاحتياطية',
        );
      }
      
      onProgress?.call('جاري تجهيز المجلد السحابي...');
      // الحصول على مجلد النسخ
      final folderId = await _getOrCreateBackupFolder();
      if (folderId == null) {
        return DriveBackupResult(
          success: false,
          errorMessage: 'تعذر الوصول إلى مساحة التخزين في Drive',
        );
      }
      
      onProgress?.call('جاري رفع الملف...');
      // إعداد ملف Drive
      final fileName = path.basename(filePath);
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [folderId];
      
      // رفع الملف
      final fileContent = await file.readAsBytes();
      final media = drive.Media(
        Stream.value(fileContent),
        fileContent.length,
      );
      
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );
      
      // حفظ تاريخ آخر نسخة
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      await prefs.setString(_lastBackupKey, '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}');
      
      onProgress?.call('جاري تحديث القائمة...');
      // تنظيف النسخ القديمة (اختياري)
      await cleanupOldBackups();
      
      return DriveBackupResult(
        success: true,
        fileId: uploadedFile.id,
        fileName: uploadedFile.name,
      );
    } catch (e) {
      debugPrint('خطأ في رفع النسخة: $e');
      return DriveBackupResult(
        success: false,
        errorMessage: _mapDriveError(e),
      );
    }
  }

  /// الحصول على قائمة النسخ الاحتياطية من Drive
  Future<List<DriveBackupInfo>> listBackups() async {
    try {
      if (!await ensureSignedIn()) return [];
      
      final folderId = await _getOrCreateBackupFolder();
      if (folderId == null) return [];
      
      final response = await _driveApi!.files.list(
        q: "'$folderId' in parents and trashed=false",
        spaces: 'drive',
        orderBy: 'createdTime desc',
        $fields: 'files(id, name, size, createdTime, modifiedTime)',
      );
      
      if (response.files == null) return [];
      
      return response.files!.map((file) => DriveBackupInfo(
        id: file.id ?? '',
        name: file.name ?? 'backup.db',
        size: int.tryParse(file.size ?? '0') ?? 0,
        createdTime: file.createdTime,
      )).toList();
    } catch (e) {
      debugPrint('خطأ في جلب قائمة النسخ: $e');
      throw _mapDriveError(e);
    }
  }

  /// تنزيل نسخة احتياطية من Drive
  Future<String?> downloadBackup({String? fileId, Function(String)? onProgress}) async {
    try {
      onProgress?.call('جاري الاتصال بـ Google Drive...');
      if (!await ensureSignedIn()) return null;
      
      String? targetFileId = fileId;
      
      // إذا لم يتم تحديد ملف، نجلب أحدث نسخة
      if (targetFileId == null) {
        final backups = await listBackups();
        if (backups.isEmpty) return null;
        targetFileId = backups.first.id;
      }
      
      onProgress?.call('جاري تنزيل الملف...');
      // تنزيل الملف
      final response = await _driveApi!.files.get(
        targetFileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      
      // حفظ الملف مؤقتاً
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/restore_${DateTime.now().millisecondsSinceEpoch}.db');
      
      final List<int> bytes = [];
      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
      }
      
      await tempFile.writeAsBytes(bytes);
      
      return tempFile.path;
    } catch (e) {
      debugPrint('خطأ في تنزيل النسخة: $e');
      throw _mapDriveError(e);
    }
  }

  /// حذف نسخة احتياطية من Drive
  Future<bool> deleteBackup(String fileId) async {
    try {
      if (!await ensureSignedIn()) return false;
      
      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      debugPrint('خطأ في حذف النسخة: $e');
      return false;
    }
  }

  /// تنظيف النسخ القديمة (الإبقاء على آخر N نسخ)
  Future<void> cleanupOldBackups({int keepCount = 5}) async {
    try {
      final backups = await listBackups();
      
      if (backups.length <= keepCount) return;
      
      debugPrint('تنظيف ${backups.length - keepCount} نسخ قديمة من Drive...');
      
      // النسخ تأتي مرتبة من الأحدث للأقدم
      // نحذف ما بعد العدد المسموح به
      for (int i = keepCount; i < backups.length; i++) {
        await deleteBackup(backups[i].id);
      }
    } catch (e) {
      debugPrint('فشل في تنظيف النسخ القديمة: $e');
      // لا نوقف العملية إذا فشل التنظيف
    }
  }

  /// تحويل أخطاء Google API إلى رسائل عربية مفهومة
  String _mapDriveError(dynamic error) {
    final e = error.toString();
    
    if (e.contains('SocketException') || e.contains('Network is unreachable')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.';
    }
    
    if (e.contains('UserRecoverableAuthException') || e.contains('401') || e.contains('403')) {
      return 'انتهت صلاحية جلسة الدخول. يرجى تسجيل الدخول مرة أخرى.';
    }
    
    if (e.contains('404') || e.contains('NotFound')) {
      return 'الملف أو المجلد غير موجود في Drive.';
    }
    
    if (e.contains('usageLimits') || e.contains('storageQuotaExceeded')) {
      return 'مساحة التخزين في Google Drive ممتلئة.';
    }

    if (e.contains('accessDenied')) {
      return 'تم رفض الوصول. تأكد من منح الصلاحيات المطلوبة للتطبيق.';
    }
    
    return 'حدث خطأ غير متوقع: ${e.length > 50 ? e.substring(0, 50) + '...' : e}';
  }
}

/// HTTP Client مخصص للتعامل مع Google Auth
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

/// نتيجة عملية الرفع
class DriveBackupResult {
  final bool success;
  final String? fileId;
  final String? fileName;
  final String? errorMessage;

  DriveBackupResult({
    required this.success,
    this.fileId,
    this.fileName,
    this.errorMessage,
  });
}

/// معلومات نسخة احتياطية في Drive
class DriveBackupInfo {
  final String id;
  final String name;
  final int size;
  final DateTime? createdTime;

  DriveBackupInfo({
    required this.id,
    required this.name,
    required this.size,
    this.createdTime,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedDate {
    if (createdTime == null) return 'غير معروف';
    return '${createdTime!.day}/${createdTime!.month}/${createdTime!.year}';
  }
}

 */
