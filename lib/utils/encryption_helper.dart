import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class EncryptionHelper {
  /// تشفير بسيط باستخدام XOR مع مفتاح مشتق من كلمة المرور
  /// ملاحظة: للإنتاج الفعلي، يُنصح باستخدام مكتبة تشفير أكثر تقدماً
  static Uint8List encryptData(Uint8List data, String password) {
    final key = _deriveKey(password);
    final encrypted = Uint8List(data.length);
    
    for (int i = 0; i < data.length; i++) {
      encrypted[i] = data[i] ^ key[i % key.length];
    }
    
    return encrypted;
  }

  /// فك تشفير البيانات
  static Uint8List decryptData(Uint8List encryptedData, String password) {
    // XOR هو عملية عكسية، لذا نستخدم نفس الدالة
    return encryptData(encryptedData, password);
  }

  /// اشتقاق مفتاح من كلمة المرور
  static Uint8List _deriveKey(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return Uint8List.fromList(hash.bytes);
  }

  /// تشفير ملف
  static Future<void> encryptFile(File inputFile, File outputFile, String password) async {
    final data = await inputFile.readAsBytes();
    final encrypted = encryptData(data, password);
    await outputFile.writeAsBytes(encrypted);
  }

  /// فك تشفير ملف
  static Future<void> decryptFile(File inputFile, File outputFile, String password) async {
    final encryptedData = await inputFile.readAsBytes();
    final decrypted = decryptData(encryptedData, password);
    await outputFile.writeAsBytes(decrypted);
  }

  /// التحقق من قوة كلمة المرور
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 4) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.medium;
    
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;
    
    if (password.length >= 12 && strength >= 3) return PasswordStrength.veryStrong;
    if (password.length >= 10 && strength >= 2) return PasswordStrength.strong;
    if (strength >= 2) return PasswordStrength.medium;
    
    return PasswordStrength.weak;
  }
}

enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
  veryStrong,
}

extension PasswordStrengthExtension on PasswordStrength {
  String get displayName {
    switch (this) {
      case PasswordStrength.empty:
        return 'فارغة';
      case PasswordStrength.weak:
        return 'ضعيفة';
      case PasswordStrength.medium:
        return 'متوسطة';
      case PasswordStrength.strong:
        return 'قوية';
      case PasswordStrength.veryStrong:
        return 'قوية جداً';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.25;
      case PasswordStrength.medium:
        return 0.5;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.veryStrong:
        return 1.0;
    }
  }
}
