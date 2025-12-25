import '../entities/backup_metadata.dart';
import '../entities/backup_result.dart';
import '../entities/restore_result.dart';
import '../entities/drive_backup_info.dart';
import '../entities/drive_backup_result.dart';

abstract class BackupRepository {
  Future<BackupResult> createLocalBackupWithName(String destinationPath, String fileName);
  Future<BackupResult> createTempBackup();
  Future<RestoreResult> restoreLocalBackup(String backupFilePath);
  Future<List<BackupMetadata>> listLocalBackups();
  Future<bool> deleteLocalBackup(String filePath);

  Future<String?> getLinkedDriveEmail();
  Future<void> unlinkDriveAccount();
  Future<String?> signInDrive();

  Future<DriveBackupResult> uploadDriveBackup(String filePath, {Function(String)? onProgress});
  Future<List<DriveBackupInfo>> listDriveBackups();
  Future<String?> downloadDriveBackup({String? fileId, Function(String)? onProgress});
}
