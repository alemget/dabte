import 'package:flutter/material.dart';

/// أيقونة مخصصة على شكل سبيكة ذهب
/// Professional Custom Gold Bar Icon
class GoldBarIcon extends StatelessWidget {
  final String karat; // 24, 22, 21, 18
  final double width;
  final double height;
  final bool showText;

  const GoldBarIcon({
    super.key,
    required this.karat,
    this.width = 24,
    this.height = 14,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // تدرج ذهبي احترافي
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE082), // Light Gold
            Color(0xFFFFD54F), // Gold
            Color(0xFFFFB300), // Deep Gold
            Color(0xFFFFA000), // Dark Gold
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(width * 0.15), // حواف ناعمة للسبيكة
        // حدود لامعة
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 0.8),
        // ظل خفيف للعمق
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: showText
          ? Text(
              _getLabel(),
              style: TextStyle(
                color: const Color(0xFF5D4037), // بني غامق للنص
                fontSize: height * 0.6,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            )
          : null,
    );
  }

  String _getLabel() {
    switch (karat) {
      case '24':
        return '999';
      case '22':
        return '22K';
      case '21':
        return '21K';
      case '18':
        return '18K';
      default:
        return 'GOLD';
    }
  }
}
