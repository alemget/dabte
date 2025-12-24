# Dabdt – Architecture & Refactor Report (Feature-first + Core)

## 1) Current status
- **Build/Run**: يعمل عندك الآن على VS Code.
- **Static Analysis**: `flutter analyze` = **No issues found**.
- **Repository**: تم رفع آخر تغييرات التنظيف إلى `https://github.com/alemget/dabte`.

> ملاحظة: ما زال مجلد `lib/ui/` موجودًا كـ **Legacy** (لم نحذفه)، لكنه **مستبعد من التحليل** حتى لا يسبب تحذيرات. الكود المعتمد حاليًا هو داخل `lib/features/` و`lib/core/`.

---

## 2) الهدف من الهيكلة الجديدة
الانتقال إلى هيكلة:
- **Feature-first**: كل ميزة (Clients/Settings/…) لها مجلد مستقل يحتوي صفحاتها وودجتاتها وحالتها.
- **Core**: كل شيء مشترك وعام (خدمات، بيانات مشتركة، ترجمة…) يكون في `core/`.

هذا يقلل التشابك، ويسهّل التطوير والصيانة، ويجعل الاعتماديات واضحة.

---

## 3) شجرة الهيكلة الجديدة (مختصرة لكن دقيقة)

> هذه الشجرة تركّز على الأجزاء التي تم ترحيلها فعليًا إلى الهيكلة الجديدة.

```text
lib/
  core/
    core.dart
    data/
      currency_data.dart
      debt_database.dart
    l10n/
      app_localizations.dart
    services/
      background_backup_service.dart
      notification_service.dart
    utils/
      encryption_helper.dart

  features/
    app_shell/
      app_shell.dart
      presentation/
        pages/
          (3 pages)

    clients/
      clients.dart
      domain/
        entities/
          (2 entity files)
      presentation/
        pages/
          add_edit_client_page.dart
          add_edit_client_page_impl.dart
          add_edit_transaction_page.dart
          client_details_page.dart
          client_details_page_impl.dart
          clients_page.dart
          clients_page_impl.dart
        state/
          (1 state file)
        utils/
          sort_utils.dart
        widgets/
          client_app_bar_actions.dart
          client_card.dart
          client_filter_sheet.dart
          client_reminders_sheet.dart
          client_search_bar.dart
          order_button.dart
          sort_option_tile.dart

    settings/
      settings.dart
      presentation/
        pages/
          about_app_page.dart
          about_app_page_impl.dart
          currencies_page.dart
          currencies_page_impl.dart
          language_settings_page.dart
          language_settings_page_impl.dart
          lock_settings_page.dart
          lock_settings_page_impl.dart
          notifications_settings_page.dart
          notifications_settings_page_impl.dart
          personal_profile_page.dart
          personal_profile_page_impl.dart
          settings_page.dart
          settings_page_impl.dart
          backup/
            backup_page.dart
            backup_page_impl.dart
            models/
              (1 model file)
            services/
              (4 service files)
            widgets/
              (2 widget files)
        widgets/
          section_title.dart
          section_title_impl.dart
          settings_card.dart
          settings_card_impl.dart
          settings_divider.dart
          settings_divider_impl.dart
          settings_tile.dart
          settings_tile_impl.dart
```

---

## 4) مبدأ الـ Facade/Export (لماذا توجد ملفات صغيرة وملفات `_impl`؟)
خلال الترحيل استخدمنا نمطًا يقلل كسر البناء:
- الملف الأساسي مثل: `clients_page.dart` يكون **واجهة (Facade)** ويعمل `export`.
- الملف الحقيقي مثل: `clients_page_impl.dart` يحتوي **التنفيذ الكامل**.

الهدف:
- ترحيل تدريجي بدون كسر.
- إبقاء مسارات الاستيراد ثابتة داخل المشروع قدر الإمكان.

---

## 5) ما الذي تم “تنظيفه”؟
- تم إصلاح تحذيرات `flutter analyze` داخل الكود الجديد.
- تم تعديل بعض النقاط التي كانت تسبب:
  - `unused_element`
  - `curly_braces_in_flow_control_structures`
  - `unnecessary_to_list_in_spreads`
  - `empty_catches`
- تم استبعاد `lib/ui/**` من التحليل لأن الهدف هو تطوير الهيكلة الجديدة بدون ضوضاء من الكود القديم.

---

## 6) ما الذي تبقّى (لإنهاء المشروع 100%)
### (A) تثبيت قواعد الاستيراد (Architecture Guardrails)
- ممنوع أي `import` من `lib/ui/**` داخل `lib/features/**` أو `lib/core/**`.
- أي شيء مشترك (خدمة/مساعد/ترجمة/ثوابت) ينقل إلى `core/`.

### (B) إزالة Legacy تدريجيًا (اختياري لكنه يكمّل الاحترافية)
- بعد التأكد أن كل الصفحات المستخدمة تم ترحيلها:
  - حذف `lib/ui/` أو نقله لأرشيف.
  - إزالة `lib/data`/`lib/models`/`lib/services` القديمة إذا لم تعد مستخدمة.

### (C) توحيد الـ Entry points
- التأكد أن `main.dart` و`app/` يستخدمان فقط `features/` و`core/`.

---

## 7) أوامر التحقق المقترحة قبل أي Release
```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

---

## 8) ملاحظة عن الحزم (Packages)
`flutter pub get` أظهر أن هناك نسخ أحدث لكثير من الحزم لكنها **غير متوافقة مع القيود الحالية**. هذا طبيعي.
إذا رغبت، نعمل جلسة خاصة لتحديث الحزم تدريجيًا بدون كسر.
