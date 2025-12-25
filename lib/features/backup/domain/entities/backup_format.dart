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
