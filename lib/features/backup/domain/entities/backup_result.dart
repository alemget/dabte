import 'backup_metadata.dart';

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
