import 'package:flutter/material.dart';

/// شريط تقدم مخصص
/// Custom progress bar widget
class CustomProgressBar extends StatelessWidget {
  /// النسبة (0.0 - 1.0)
  final double progress;

  /// اللون
  final Color color;

  /// لون الخلفية
  final Color? backgroundColor;

  /// الارتفاع
  final double height;

  /// نصف قطر الحواف
  final double borderRadius;

  const CustomProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
