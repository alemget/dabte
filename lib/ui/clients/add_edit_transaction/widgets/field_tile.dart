import 'package:flutter/material.dart';

/// حقل إدخال مع تصميم موحد
class FieldTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isError;
  final VoidCallback onTap;
  final Color mutedColor;
  final Color textColor;
  final Color surfaceColor;
  final Widget? trailing;

  static const _red = Color(0xFFEF4444);

  const FieldTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isError = false,
    required this.onTap,
    required this.mutedColor,
    required this.textColor,
    required this.surfaceColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: mutedColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 10, color: mutedColor),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isError ? _red : textColor,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_left_rounded, size: 20, color: mutedColor),
          ],
        ),
      ),
    );
  }
}
