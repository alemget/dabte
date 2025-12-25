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
