import '../domain/entities/backup_metadata.dart';
import '../domain/entities/backup_result.dart';
import '../domain/entities/restore_result.dart';
import '../domain/entities/drive_backup_info.dart';
import '../domain/entities/drive_backup_result.dart';
import '../domain/repositories/backup_repository.dart';
import 'datasources/local_backup_service.dart' hide BackupResult, RestoreResult;
import 'datasources/drive_backup_service.dart' hide DriveBackupResult, DriveBackupInfo;

class BackupRepositoryImpl implements BackupRepository {
  final LocalBackupService _local;
  final DriveBackupService _drive;

  BackupRepositoryImpl({
    LocalBackupService? local,
    DriveBackupService? drive,
  })  : _local = local ?? LocalBackupService.instance,
        _drive = drive ?? DriveBackupService.instance;

  @override
  Future<BackupResult> createLocalBackupWithName(String destinationPath, String fileName) async {
    return await _local.createBackupWithName(destinationPath, fileName);
  }

  @override
  Future<BackupResult> createTempBackup() async {
    return await _local.createTempBackup();
  }

  @override
  Future<RestoreResult> restoreLocalBackup(String backupFilePath) async {
    return await _local.restoreBackup(backupFilePath);
  }

  @override
  Future<List<BackupMetadata>> listLocalBackups() async {
    return await _local.listBackups();
  }

  @override
  Future<bool> deleteLocalBackup(String filePath) async {
    return await _local.deleteBackup(filePath);
  }

  @override
  Future<String?> getLinkedDriveEmail() async {
    return await _drive.getLinkedEmail();
  }

  @override
  Future<void> unlinkDriveAccount() async {
    await _drive.unlinkAccount();
  }

  @override
  Future<String?> signInDrive() async {
    final account = await _drive.signIn();
    return account?.email;
  }

  @override
  Future<DriveBackupResult> uploadDriveBackup(String filePath, {Function(String)? onProgress}) async {
    return await _drive.uploadBackup(filePath, onProgress: onProgress);
  }

  @override
  Future<List<DriveBackupInfo>> listDriveBackups() async {
    return await _drive.listBackups();
  }

  @override
  Future<String?> downloadDriveBackup({String? fileId, Function(String)? onProgress}) async {
    return await _drive.downloadBackup(fileId: fileId, onProgress: onProgress);
  }
}
