# هيكل مشروع Debt Max 📁

## 📂 الهيكل الحالي (بعد التنظيف)

```
lib/
├── main.dart                       ← نقطة البداية
├── PROJECT_STRUCTURE.md
│
├── app/                            ← إعداد التطبيق
│   ├── app.dart                    ← MaterialApp + Theme
│   └── bootstrap.dart              ← تهيئة الخدمات
│
├── data/                           ← طبقة البيانات
│   ├── debt_database.dart          ← SQLite
│   ├── currency_data.dart          ← قائمة العملات
│   └── repositories/
│       └── client_repository.dart
│
├── models/                         ← نماذج البيانات
│   ├── client.dart
│   └── transaction.dart
│
├── providers/                      ← إدارة الحالة
│   ├── client_provider.dart
│   └── language_provider.dart
│
├── services/
│   └── notification_service.dart   ← الإشعارات
│
├── utils/
│   └── encryption_helper.dart      ← التشفير
│
├── l10n/                           ← الترجمة (AR/EN)
│
└── ui/                             ← واجهة المستخدم
    ├── main_screen.dart
    ├── lock_screen.dart
    ├── splash_screen.dart
    │
    ├── clients/                    ← قسم العملاء
    │   ├── clients_page.dart
    │   ├── client_details_page.dart
    │   ├── add_edit_client_page.dart
    │   ├── add_edit_transaction_page.dart
    │   ├── components/             ← مكونات (bottom sheets)
    │   ├── widgets/                ← widgets قابلة للاستخدام
    │   ├── utils/                  ← أدوات مساعدة
    │   ├── add_edit_transaction/   ← 📦 widgets مستخرجة
    │   │   ├── models/
    │   │   └── widgets/
    │   └── client_details/         ← 📦 widgets مستخرجة
    │       ├── models/
    │       └── widgets/
    │
    └── settings/                   ← قسم الإعدادات
        ├── settings_page.dart
        ├── currencies_page.dart
        ├── lock_settings_page.dart
        ├── personal_profile_page.dart
        ├── language_settings_page.dart
        ├── about_app_page.dart
        ├── notifications_settings_page.dart
        ├── widgets/
        └── backup/                 ← النسخ الاحتياطي
            ├── backup_page.dart
            ├── services/
            ├── models/
            └── widgets/
```

---

## 📊 إحصائيات المشروع

| المقياس | القيمة |
|---------|--------|
| إجمالي الملفات | 59 ملف .dart |
| الحجم الإجمالي | ~550 KB |

*آخر تحديث: 24 ديسمبر 2024*
