import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:dabdt/features/backup/domain/entities/backup_metadata.dart';
import 'package:dabdt/features/backup/data/datasources/local_backup_service.dart';

/// ويدجت لعرض قائمة النسخ الاحتياطية المتاحة
class BackupListWidget extends StatefulWidget {
  final VoidCallback? onRestoreComplete;
  final VoidCallback? onBackupDeleted;

  const BackupListWidget({
    super.key,
    this.onRestoreComplete,
    this.onBackupDeleted,
  });

  @override
  State<BackupListWidget> createState() => _BackupListWidgetState();
}

class _BackupListWidgetState extends State<BackupListWidget> {
  List<BackupMetadata> _backups = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final backups = await LocalBackupService.instance.listBackups();
      if (mounted) {
        setState(() {
          _backups = backups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل في تحميل قائمة النسخ الاحتياطية';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteBackup(BackupMetadata backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('تأكيد الحذف', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل تريد حذف هذه النسخة الاحتياطية؟',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      backup.fileName,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${backup.formattedDate} • ${backup.formattedSize}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('حذف', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final success = await LocalBackupService.instance.deleteBackup(backup.filePath);
      if (success) {
        await _loadBackups();
        widget.onBackupDeleted?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف النسخة الاحتياطية'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _shareBackup(BackupMetadata backup) {
    Share.shareXFiles(
      [XFile(backup.filePath)],
      text: 'نسخة احتياطية: ${backup.fileName}',
    );
  }

  Future<void> _restoreBackup(BackupMetadata backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.restore, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text('تأكيد الاستعادة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE4B5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFF59E0B)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم استبدال جميع البيانات الحالية',
                        style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.insert_drive_file, 'الملف:', backup.fileName),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.access_time, 'التاريخ:', backup.formattedDate),
                    const SizedBox(height: 6),
                    _buildInfoRow(Icons.storage, 'الحجم:', backup.formattedSize),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('استعادة', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      // عرض مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري استعادة البيانات...', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      );

      final result = await LocalBackupService.instance.restoreBackup(backup.filePath);

      if (mounted) {
        Navigator.pop(context); // إغلاق مؤشر التحميل

        if (result.success) {
          widget.onRestoreComplete?.call();
          showDialog(
            context: context,
            builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text('تمت الاستعادة بنجاح', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (result.clientsCount != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'تم استعادة ${result.clientsCount} عميل',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('حسناً', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('فشلت الاستعادة', style: TextStyle(fontSize: 14)),
                  ],
                ),
                content: Text(
                  result.errorMessage ?? 'حدث خطأ غير متوقع',
                  style: const TextStyle(fontSize: 12),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('حسناً', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: TextStyle(fontSize: 11, color: Colors.red.shade700),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: _loadBackups,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    }

    if (_backups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.backup, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'لا توجد نسخ احتياطية محفوظة',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'قم بإنشاء نسخة احتياطية للحفاظ على بياناتك',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        Row(
          children: [
            Icon(Icons.folder_open, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              'النسخ المحفوظة (${_backups.length})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.refresh, size: 16, color: Colors.grey.shade600),
              onPressed: _loadBackups,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'تحديث',
            ),
          ],
        ),
        const SizedBox(height: 8),

        // قائمة النسخ
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _backups.length > 5 ? 5 : _backups.length, // عرض آخر 5 نسخ
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final backup = _backups[index];
              return _BackupItem(
                backup: backup,
                isFirst: index == 0,
                onRestore: () => _restoreBackup(backup),
                onShare: () => _shareBackup(backup),
                onDelete: () => _deleteBackup(backup),
              );
            },
          ),
        ),

        // رسالة إذا كان هناك المزيد
        if (_backups.length > 5) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'و ${_backups.length - 5} نسخ أخرى',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ),
        ],
      ],
    );
  }
}

/// عنصر نسخة احتياطية واحدة
class _BackupItem extends StatelessWidget {
  final BackupMetadata backup;
  final bool isFirst;
  final VoidCallback onRestore;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _BackupItem({
    required this.backup,
    required this.isFirst,
    required this.onRestore,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRestore,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // أيقونة
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isFirst ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.backup,
                size: 18,
                color: isFirst ? const Color(0xFF10B981) : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 10),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          backup.fileName,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isFirst)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'الأحدث',
                            style: TextStyle(fontSize: 8, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${backup.timeAgo} • ${backup.formattedSize}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // أزرار الإجراءات
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.share, size: 16, color: Colors.blue.shade600),
                  onPressed: onShare,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  tooltip: 'مشاركة',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade400),
                  onPressed: onDelete,
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  tooltip: 'حذف',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
