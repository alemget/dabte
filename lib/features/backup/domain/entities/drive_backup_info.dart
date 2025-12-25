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
