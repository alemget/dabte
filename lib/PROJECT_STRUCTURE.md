# هيكل مشروع Debt Max 📁

## 📂 الهيكل الحالي

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
    │   ├── clients_list/
    │   │   └── clients_page.dart
    │   ├── client_details/
    │   │   ├── client_details_page.dart
    │   │   ├── models/
    │   │   ├── widgets/
    │   │   └── utils/
    │   ├── add_edit_client/
    │   ├── add_edit_transaction/
    │   ├── components/
    │   ├── widgets/
    │   └── utils/
    │
    ├── reports/                    ← 📊 قسم التقارير (جديد)
    │   ├── reports_page.dart       ← الصفحة الرئيسية
    │   ├── models/                 ← نماذج البيانات
    │   │   ├── models.dart
    │   │   ├── report_summary.dart
    │   │   ├── client_debt_info.dart
    │   │   ├── transaction_stats.dart
    │   │   └── currency_breakdown.dart
    │   ├── services/               ← خدمات جلب البيانات
    │   │   ├── services.dart
    │   │   └── reports_service.dart
    │   └── widgets/                ← الويدجتس
    │       ├── widgets.dart
    │       ├── stat_card.dart
    │       ├── stat_tile.dart
    │       ├── section_card.dart
    │       ├── custom_progress_bar.dart
    │       ├── summary_card.dart
    │       ├── clients_overview_card.dart
    │       ├── transactions_report_card.dart
    │       └── currency_report_card.dart
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
        └── backup/
            ├── backup_page.dart
            ├── services/
            ├── models/
            └── widgets/
```

---

## 📊 إحصائيات المشروع

| المقياس | القيمة |
|---------|--------|
| إجمالي الملفات | ~75 ملف .dart |
| الحجم الإجمالي | ~600 KB |

*آخر تحديث: 25 ديسمبر 2024*

