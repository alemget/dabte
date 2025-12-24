/// نموذج معلومات النسخة الاحتياطية
/// يحتوي على جميع المعلومات الوصفية للنسخة الاحتياطية

class BackupMetadata {
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final int fileSizeBytes;
  final String appVersion;
  final int clientsCount;
  final int transactionsCount;
  final String? checksum;
  final BackupFormat format;
  final bool isEncrypted;

  BackupMetadata({
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.fileSizeBytes,
    this.appVersion = '1.0.0',
    this.clientsCount = 0,
    this.transactionsCount = 0,
    this.checksum,
    this.format = BackupFormat.v2,
    this.isEncrypted = true,
  });

  /// حجم الملف بصيغة مقروءة
  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// تاريخ النسخة بصيغة مقروءة
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} - ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// وقت منذ الإنشاء
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  /// تحويل من Map
  factory BackupMetadata.fromMap(Map<String, dynamic> map) {
    return BackupMetadata(
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      fileSizeBytes: map['fileSizeBytes'] ?? 0,
      appVersion: map['appVersion'] ?? '1.0.0',
      clientsCount: map['clientsCount'] ?? 0,
      transactionsCount: map['transactionsCount'] ?? 0,
      checksum: map['checksum'],
      format: BackupFormat.values.firstWhere(
        (e) => e.name == map['format'],
        orElse: () => BackupFormat.v1,
      ),
      isEncrypted: map['isEncrypted'] ?? true,
    );
  }

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'fileSizeBytes': fileSizeBytes,
      'appVersion': appVersion,
      'clientsCount': clientsCount,
      'transactionsCount': transactionsCount,
      'checksum': checksum,
      'format': format.name,
      'isEncrypted': isEncrypted,
    };
  }

  /// إنشاء من ملف
  static BackupMetadata fromFile({
    required String fileName,
    required String filePath,
    required int fileSize,
    DateTime? createdAt,
  }) {
    // محاولة استخراج التاريخ من اسم الملف
    DateTime parsedDate = createdAt ?? DateTime.now();
    
    // تنسيق الاسم: backup_YYYYMMDD_HHMM.db
    final regex = RegExp(r'backup_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})');
    final match = regex.firstMatch(fileName);
    
    if (match != null) {
      try {
        parsedDate = DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
          int.parse(match.group(4)!),
          int.parse(match.group(5)!),
        );
      } catch (e) {
        // استخدام التاريخ الافتراضي
      }
    }

    return BackupMetadata(
      fileName: fileName,
      filePath: filePath,
      createdAt: parsedDate,
      fileSizeBytes: fileSize,
      format: _detectFormat(fileName),
    );
  }

  /// اكتشاف صيغة النسخة
  static BackupFormat _detectFormat(String fileName) {
    if (fileName.endsWith('.dbk')) {
      return BackupFormat.v2;
    }
    return BackupFormat.v1;
  }
}

/// صيغ النسخ الاحتياطية
enum BackupFormat {
  /// الصيغة القديمة (XOR encryption)
  v1,
  
  /// الصيغة الجديدة (محسّنة)
  v2,
}

extension BackupFormatExtension on BackupFormat {
  String get displayName {
    switch (this) {
      case BackupFormat.v1:
        return 'الصيغة الأصلية';
      case BackupFormat.v2:
        return 'الصيغة المحسّنة';
    }
  }

  String get fileExtension {
    switch (this) {
      case BackupFormat.v1:
        return 'db';
      case BackupFormat.v2:
        return 'db'; // نستخدم نفس الامتداد للتوافق
    }
  }
}
