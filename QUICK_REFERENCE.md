# 📋 بطاقة مرجعية سريعة - Google Cloud Setup

## معلومات المشروع الأساسية

```
اسم التطبيق: DioMax
Package Name: com.diomax.app
```

## الخطوات الرئيسية (5 مهام)

### 1️⃣ إنشاء المشروع
- اذهب إلى: https://console.cloud.google.com/
- اسم المشروع: `DioMax`

### 2️⃣ تفعيل API
- **Google Drive API** → ENABLE

### 3️⃣ OAuth Consent Screen
- Type: **External**
- App name: `DioMax`
- Email: بريدك الإلكتروني

### 4️⃣ إنشاء OAuth Client ID
- Type: **Android**
- Name: `DioMax Android Debug`
- Package: `com.diomax.app`
- SHA-1: (من السكريبت أدناه)

### 5️⃣ اختبار
```bash
flutter run
```

## الحصول على SHA-1

```powershell
.\get_sha1.ps1
```

سينسخ SHA-1 تلقائياً إلى clipboard

## قائمة التحقق السريعة

```
✓ المشروع تم إنشاؤه
✓ Google Drive API مفعّل
✓ OAuth Consent Screen جاهز
✓ OAuth Client ID (Android) تم إنشاؤه
  ├─ Package: com.diomax.app ✓
  └─ SHA-1: تم إضافته ✓
```

## أخطاء شائعة

| الخطأ | السبب | الحل |
|------|-------|------|
| ApiException: 10 | SHA-1 خاطئ | تحقق من Package name و SHA-1 |
| sign_in_failed | OAuth غير موجود | أنشئ OAuth Client ID |
| 403 Access Denied | API غير مفعّل | فعّل Google Drive API |

## روابط مهمة

- Console: https://console.cloud.google.com/
- APIs Library: https://console.cloud.google.com/apis/library
- Credentials: https://console.cloud.google.com/apis/credentials

---

**راجع الدليل الكامل:** `google_cloud_setup_ar.md`
