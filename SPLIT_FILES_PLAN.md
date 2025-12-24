# خطة تقسيم الملفات الكبيرة إلى مجلدات وملفات أصغر

---

## 1) الملفات المستهدفة (حجمها كبير جدًا)

| الملف | الحجم (سطور) | الميزة | المشكلة |
|-------|--------------|--------|----------|
| `client_details_page.dart` | 1367 | Clients | صفحة العميل + كل الودجتات + الحسابات في ملف واحد |
| `backup_page.dart` | 2446 | Settings | صفحة النسخ الاحتياطي + كل الأقسام + خدمات في ملف واحد |
| `currencies_page.dart` | 927 | Settings | صفحة العملات + كل النماذج + التحقق في ملف واحد |
| `add_edit_transaction_page.dart` | 895 | Clients | نافذة إضافة/تعديل معاملة + كل الفورم في ملف واحد |

---

## 2) خطة التقسيم لكل ملف

### 2.1) Client Details Page (1367 سطر)

#### الهيكل الحالي
```
lib/ui/clients/client_details_page.dart
```

#### الهيكل المقترح بعد التقسيم
```
lib/ui/clients/
  client_details_page.dart (واجهة/export فقط)
  client_details/
    client_details_page_impl.dart (الصفحة الرئيسية فقط، ~200 سطر)
    components/
      client_summary_card.dart (بطاقة ملخص الدين)
      currency_summary_section.dart (قسم ملخص العملات)
      transaction_list_section.dart (قائمة المعاملات)
      transaction_item.dart (عنصر معاملة واحدة)
      empty_state_widget.dart (حالة فارغة)
    dialogs/
      add_transaction_dialog.dart (نافذة إضافة معاملة)
      edit_client_dialog.dart (نافذة تعديل العميل)
      delete_confirmation_dialog.dart (تأكيد الحذف)
    actions/
      client_details_app_bar.dart (أزرار شريط التطبيق)
      floating_action_button.dart (زر الإضافة العائم)
    helpers/
      currency_formatter.dart (تنسيق العملات)
      date_formatter.dart (تنسيق التواريخ)
      transaction_calculator.dart (حسابات المعاملات)
```

#### ماذا يذهب أين؟
- **UI فقط**: `components/` و `dialogs/` و `actions/`
- **منطق حسابي**: `helpers/transaction_calculator.dart`
- **تنسيق**: `helpers/currency_formatter.dart` و `helpers/date_formatter.dart`

---

### 2.2) Backup Page (2446 سطر)

#### الهيكل الحالي
```
lib/ui/settings/backup/backup_page.dart
```

#### الهيكل المقترح بعد التقسيم
```
lib/ui/settings/backup/
  backup_page.dart (واجهة/export فقط)
  backup/
    backup_page_impl.dart (الصفحة الرئيسية فقط، ~200 سطر)
    sections/
      local_backup_section.dart (قسم النسخ المحلي)
      drive_backup_section.dart (قسم نسخ Drive)
      auto_backup_settings_section.dart (إعدادات النسخ التلقائي)
      backup_history_section.dart (سجل النسخ)
    components/
      backup_action_button.dart (زر النسخ)
      backup_progress_dialog.dart (نافذة التقدم)
      backup_list_item.dart (عنصر في قائمة النسخ)
      permission_guide_dialog.dart (دليل الأذونات)
      settings_switch.dart (مفتاح الإعدادات)
    forms/
      frequency_selector.dart (اختيار التكرار)
      time_picker_dialog.dart (اختيار الوقت)
      path_selector.dart (اختيار المسار)
      drive_account_selector.dart (اختيار حساب Drive)
    services/
      local_backup_service.dart (خدمة النسخ المحلي)
      drive_backup_service.dart (خدمة نسخ Drive)
      backup_file_manager.dart (إدارة ملفات النسخ)
    models/
      backup_config.dart (إعدادات النسخ)
      backup_metadata.dart (بيانات وصفية)
```

---

### 2.3) Currencies Page (927 سطر)

#### الهيكل الحالي
```
lib/ui/settings/currencies_page.dart
```

#### الهيكل المقترح بعد التقسيم
```
lib/ui/settings/
  currencies_page.dart (واجهة/export فقط)
  currencies/
    currencies_page_impl.dart (الصفحة الرئيسية فقط، ~150 سطر)
    components/
      currency_list_item.dart (عنصر عملة)
      currency_list_section.dart (قائمة العملات)
      add_currency_button.dart (زر إضافة عملة)
    dialogs/
      add_currency_dialog.dart (نافذة إضافة عملة)
      edit_currency_dialog.dart (نافذة تعديل عملة)
      delete_currency_dialog.dart (نافذة حذف عملة)
    forms/
      currency_form.dart (نموذج إدخال العملة)
      exchange_rate_input.dart (حقل إدخال سعر الصرف)
    validators/
      currency_validator.dart (التحقق من صحة البيانات)
      exchange_rate_validator.dart (التحقق من سعر الصرف)
    helpers/
      currency_formatter.dart (تنسيق العملات)
      currency_calculator.dart (حسابات العملات)
```

---

### 2.4) Add/Edit Transaction Page (895 سطر)

#### الهيكل الحالي
```
lib/ui/clients/add_edit_transaction_page.dart
```

#### الهيكل المقترح بعد التقسيم
```
lib/ui/clients/
  add_edit_transaction_page.dart (واجهة/export فقط)
  transaction/
    add_edit_transaction_page_impl.dart (الصفحة الرئيسية فقط، ~150 سطر)
    components/
      client_selector.dart (اختيار العميل)
      amount_input_field.dart (حقل إدخال المبلغ)
      currency_selector.dart (اختيار العملة)
      date_time_picker.dart (اختيار التاريخ والوقت)
      notes_field.dart (حقل الملاحظات)
      transaction_type_selector.dart (اختيار نوع المعاملة)
    dialogs/
      transaction_dialog.dart (نافذة المعاملة)
    forms/
      transaction_form.dart (نموذج المعاملة)
    validators/
      transaction_validator.dart (التحقق من صحة المدخلات)
      amount_validator.dart (التحقق من المبلغ)
    helpers/
      amount_formatter.dart (تنسيق المبالغ)
      transaction_helper.dart (مساعدات المعاملات)
```

---

## 3) خطوات التنفيذ (Step-by-Step)

### الخطوة 1: إنشاء المجلدات الفارغة
```bash
# Client Details
mkdir -p lib/ui/clients/client_details/{components,dialogs,actions,helpers}

# Backup
mkdir -p lib/ui/settings/backup/backup/{sections,components,forms,services,models}

# Currencies
mkdir -p lib/ui/settings/currencies/{components,dialogs,forms,validators,helpers}

# Transaction
mkdir -p lib/ui/clients/transaction/{components,dialogs,forms,validators,helpers}
```

### الخطوة 2: تقسيم Client Details
1. قراءة `client_details_page.dart`
2. استخراج كل `Widget` إلى ملف منفصل في `components/`
3. استخراج كل `showDialog` إلى ملف منفصل في `dialogs/`
4. استخراج كل دالة مساعدة إلى `helpers/`
5. تحديث الـ imports في الصفحة الرئيسية

### الخطوة 3: تقسيم Backup
1. قراءة `backup_page.dart`
2. تقسيم الأقسام الرئيسية إلى `sections/`
3. تقسيم الودجتات الصغيرة إلى `components/`
4. تقسيم النماذج إلى `forms/`
5. فصل الخدمات إلى `services/`

### الخطوة 4: تقسيم Currencies
1. قراءة `currencies_page.dart`
2. فصل قائمة العملات إلى `components/`
3. فصل النوافذ المنبثقة إلى `dialogs/`
4. فصل النماذج إلى `forms/`
5. فصل التحقق إلى `validators/`

### الخطوة 5: تقسيم Transaction
1. قراءة `add_edit_transaction_page.dart`
2. فصل حقول الإدخال إلى `components/`
3. فصل النافذة إلى `dialogs/`
4. فصل النموذج إلى `forms/`
5. فصل التحقق إلى `validators/`

### الخطوة 6: التنظيف النهائي
1. حذف الملفات الكبيرة القديمة
2. تشغيل `flutter analyze`
3. تشغيل `flutter run` للتأكد من عدم كسر الوظائف
4. عمل `git commit` لكل ملف مقسم

---

## 4) أمثلة على الأكواد بعد التقسيم

### مثال: `client_summary_card.dart`
```dart
import 'package:flutter/material.dart';
import '../helpers/currency_formatter.dart';
import '../helpers/transaction_calculator.dart';

class ClientSummaryCard extends StatelessWidget {
  final double forMe;
  final double onMe;
  
  const ClientSummaryCard({
    super.key,
    required this.forMe,
    required this.onMe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ملخص الدين', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildDebtRow('عليّ', onMe),
            _buildDebtRow('ليّ', forMe),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
```

### مثال: `backup_page_impl.dart`
```dart
import 'package:flutter/material.dart';
import 'sections/local_backup_section.dart';
import 'sections/drive_backup_section.dart';
import 'sections/auto_backup_settings_section.dart';
import 'sections/backup_history_section.dart';

class BackupPageImpl extends StatefulWidget {
  const BackupPageImpl({super.key});

  @override
  State<BackupPageImpl> createState() => _BackupPageImplState();
}

class _BackupPageImplState extends State<BackupPageImpl> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('النسخ الاحتياطي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            LocalBackupSection(),
            SizedBox(height: 24),
            DriveBackupSection(),
            SizedBox(height: 24),
            AutoBackupSettingsSection(),
            SizedBox(height: 24),
            BackupHistorySection(),
          ],
        ),
      ),
    );
  }
}
```

---

## 5) الفوائد المتوقعة

- **سهولة القراءة**: كل ملف ≤ 200 سطر
- **سهولة الصيانة**: تعديل جزء معين دون التأثير على البقية
- **إعادة الاستخدام**: components يمكن استخدامها في أماكن أخرى
- **اختبار أسهل**: كل جزء يمكن اختباره بشكل مستقل
- **Git نظيف**: تغييرات صغيرة وواضحة في كل commit

---

## 6) متطلبات الأدوات

- **VS Code**: استخدم "Split Editor" لعرض ملفات متعددة
- **Flutter**: استخدم `flutter analyze` بعد كل تغيير
- **Git**: استخدم `git add -p` لمراجعة التغييرات قبل commit

---

## 7) الترتيب المقترح للتنفيذ

1. **Client Details** (الأكثر استخدامًا)
2. **Currencies** (الأبسط)
3. **Transaction** (يعتمد على Client Details)
4. **Backup** (الأكثر تعقيدًا)

---

## 8) التالي

هل تريد أن نبدأ بتقسيم **Client Details** أولاً؟
أم تفضل ترتيب مختلف؟
