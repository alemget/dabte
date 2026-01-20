# معلومات Google Sign-In Configuration للمشروع

## معلومات التطبيق

**Package Name:** `com.diomax.app`
**Application ID:** `com.diomax.app`

## Google Drive API Scopes المستخدمة

```dart
scopes: [
  'email',
  drive.DriveApi.driveFileScope, // Access to files created by the app only
]
```

## الإعدادات المطلوبة في Google Cloud Console

### 1. Project Setup
- اسم المشروع المقترح: `DioMax` أو `Debt Max`
- يجب تفعيل Google Drive API

### 2. OAuth 2.0 Client IDs المطلوبة

#### للتطوير (Debug):
- **Type:** Android
- **Name:** DioMax Android Debug
- **Package name:** `com.diomax.app`
- **SHA-1:** [يجب الحصول عليه من get_sha1.ps1]

#### للإنتاج (Release):
- **Type:** Android
- **Name:** DioMax Android Release
- **Package name:** `com.diomax.app`
- **SHA-1:** [من release keystore]

## كيفية الحصول على SHA-1

### للتطوير (Debug Build):
```powershell
# تشغيل السكريبت التلقائي
.\get_sha1.ps1
```

أو يدوياً:
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### للإنتاج (Release Build):
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload
```

## التحقق من التكوين

1. ✅ Google Drive API مفعّل في Google Cloud Console
2. ✅ OAuth Client ID مُنشأ للأندرويد
3. ✅ SHA-1 fingerprint مسجّل بشكل صحيح
4. ✅ Package name صحيح: `com.diomax.app`
5. ✅ Scopes صحيحة في الكود

## روابط مهمة

- Google Cloud Console: https://console.cloud.google.com/
- Google APIs Library: https://console.cloud.google.com/apis/library
- Credentials: https://console.cloud.google.com/apis/credentials

## أخطاء شائعة

### ApiException: 10 (DEVELOPER_ERROR)
**السبب:** SHA-1 غير مسجل أو package name غير متطابق
**الحل:** تحقق من OAuth Client ID في Google Cloud Console

### sign_in_failed
**السبب:** OAuth Client ID غير موجود للأندرويد
**الحل:** أنشئ OAuth Client ID جديد من نوع Android

### 403: Access Denied
**السبب:** Google Drive API غير مفعّل
**الحل:** فعّل API من APIs Library

## ملاحظات

- التغييرات في Google Cloud Console قد تستغرق 5-10 دقائق للتفعيل
- إذا قمت بتغيير SHA-1، قم بإلغاء تثبيت التطبيق وإعادة التثبيت
- احتفظ بنسخة من SHA-1 للإنتاج في مكان آمن
