# خطة تقسيم الكود الكبير إلى مجلدات وملفات أصغر (Code Split Plan)

## 1) لماذا التقسيم؟
- الملفات الحالية مثل `client_details_page.dart` (1367 سطر) و `backup_page.dart` (2446 سطر) كبيرة جدًا
- صعوبة القراءة والصيانة
- صعوبة مراجعة الكود في Git
- صعوبة إعادة استخدام الأجزاء
- مخاطر التكرار والترابط الزائد

---

## 2) مبادئ التقسيم (Professional Guidelines)
### (A) مبدأ المسؤولية الواحدة (Single Responsibility)
- كل ملف/مجلد له وظيفة واضحة واحدة.
- لا تخلط بين UI و Business Logic و Data Access في نفس الملف.

### (B) مبدأ التسلسل الهرمي (Layered)
- `presentation/` → UI فقط (Pages/Widgets/Components)
- `domain/` → منطق العمل الكامل (Entities/Use Cases)
- `data/` → مصادر البيانات فقط (Repositories/Models)

### (C) مبدأ إعادة الاستخدام (Reusable)
- أي عنصر يمكن استخدامه في أكثر من مكان → في `widgets/` أو `components/`
- أي منطق يمكن استخدامه في أكثر من مكان → في `domain/` أو `core/`

---

## 3) خطة تقسيم احترافية حسب كل ميزة

### 3.1) Clients Feature

#### الحالة الحالية (ملف واحد كبير):
```
client_details_page.dart (1367 سطر)
```

#### التقسيم المقترح:
```
features/clients/
  presentation/
    pages/
      client_details_page.dart (Facade/export)
      client_details/
        client_details_page_impl.dart (الصفحة الرئيسية فقط)
        components/
          client_summary_card.dart (بطاقة ملخص الدين)
          currency_summary_section.dart (قسم ملخص العملات)
          transaction_list_section.dart (قائمة المعاملات)
          transaction_item.dart (عنصر معاملة واحدة)
        dialogs/
          add_transaction_dialog.dart (نافذة إضافة معاملة)
          edit_client_dialog.dart (نافذة تعديل العميل)
        actions/
          client_details_app_bar.dart (أزرار شريط التطبيق)
          floating_action_button.dart (زر الإضافة العائم)
        formatters/
          currency_formatter.dart (تنسيق العملات)
          date_formatter.dart (تنسيق التواريخ)
```

#### ماذا يذهب أين؟
- **UI فقط**: `components/` و `dialogs/` و `actions/`
- **منطق حسابي**: `domain/calculations/`
- **تنسيق**: `formatters/`

---

### 3.2) Transactions (Add/Edit)

#### الحالة الحالية:
```
add_edit_transaction_page.dart (895 سطر)
```

#### التقسيم المقترح:
```
features/clients/
  presentation/
    pages/
      add_edit_transaction_page.dart (Facade/export)
      add_edit_transaction/
        add_edit_transaction_page_impl.dart (الصفحة الرئيسية)
        components/
          client_selector.dart (اختيار العميل)
          amount_input_field.dart (حقل إدخال المبلغ)
          currency_selector.dart (اختيار العملة)
          date_time_picker.dart (اختيار التاريخ والوقت)
          notes_field.dart (حقل الملاحظات)
        validators/
          transaction_validator.dart (التحقق من صحة المدخلات)
        formatters/
          amount_formatter.dart (تنسيق المبالغ)
```

---

### 3.3) Settings Feature

#### الحالة الحالية:
```
backup_page.dart (2446 سطر)
currencies_page.dart (927 سطر)
```

#### التقسيم المقترح لـ Backup:
```
features/settings/
  presentation/
    pages/
      backup_page.dart (Facade/export)
      backup/
        backup_page_impl.dart (الصفحة الرئيسية فقط)
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
        forms/
          frequency_selector.dart (اختيار التكرار)
          time_picker_dialog.dart (اختيار الوقت)
          path_selector.dart (اختيار المسار)
```

#### التقسيم المقترح لـ Currencies:
```
features/settings/
  presentation/
    pages/
      currencies_page.dart (Facade/export)
      currencies/
        currencies_page_impl.dart (الصفحة الرئيسية)
        components/
          currency_list_item.dart (عنصر عملة)
          add_currency_dialog.dart (نافذة إضافة عملة)
          edit_currency_dialog.dart (نافذة تعديل عملة)
          exchange_rate_input.dart (حقل إدخال سعر الصرف)
        forms/
          currency_form.dart (نموذج إدخال العملة)
        validators/
          currency_validator.dart (التحقق من صحة البيانات)
```

---

### 3.4) Domain Layer (منطق العمل)

#### إضافة مجلدات جديدة:
```
features/clients/
  domain/
    entities/
      client_summary.dart (ملخص العميل)
      transaction_summary.dart (ملخص المعاملات)
      debt_calculation.dart (حسابات الديون)
    use_cases/
      calculate_client_debt.dart (حساب دين العميل)
      get_transaction_history.dart (جلب سجل المعاملات)
      validate_transaction_data.dart (التحقق من صحة المعاملة)
    services/
      currency_converter.dart (تحويل العملات)
      transaction_formatter.dart (تنسيق المعاملات)

features/settings/
  domain/
    entities/
      backup_config.dart (إعدادات النسخ)
      currency_config.dart (إعدادات العملات)
    use_cases/
      validate_backup_path.dart (التحقق من مسار النسخ)
      calculate_backup_size.dart (حساب حجم النسخ)
      detect_currency_conflicts.dart (كشف تعارضات العملات)
```

---

## 4) خطوات التنفيذ (Step-by-Step)

### المرحلة 1: التحضير
1. **إنشاء المجلدات الفارغة** حسب الخطة أعلاه.
2. **إنشاء ملفات facade/export** جديدة.
3. **تحديث main.dart** ليشير إلى الملفات الجديدة.

### المرحلة 2: تقسيم Client Details
1. **إنشاء `client_details/`** ومجلداته الفرعية.
2. **نقل الـ UI** إلى `components/` و `dialogs/`.
3. **نقل الحسابات** إلى `domain/calculations/`.
4. **نقل التنسيق** إلى `formatters/`.
5. **تحديث الـ imports** في الصفحة الرئيسية.

### المرحلة 3: تقسيم Transactions
1. **إنشاء `add_edit_transaction/`**.
2. **فصل الـ components** (حقل المبلغ، اختيار العميل، إلخ).
3. **نقل التحقق** إلى `validators/`.
4. **تحديث الصفحة الرئيسية** لتستخدم الـ components.

### المرحلة 4: تقسيم Settings
1. **تقسيم Backup** إلى `sections/` و `components/`.
2. **تقسيم Currencies** إلى `components/` و `forms/`.
3. **نقل منطق الأعمال** إلى `domain/`.

### المرحلة 5: التنظيف النهائي
1. **حذف الملفات الكبيرة القديمة**.
2. **تشغيل `flutter analyze`** للتأكد من عدم وجود أخطاء.
3. **تشغيل `flutter test`** للتأكد من عدم كسر الوظائف.
4. **عمل commit** لكل مرحلة على حدة.

---

## 5) أمثلة على الأكواد بعد التقسيم

### مثال: `client_summary_card.dart`
```dart
import 'package:flutter/material.dart';
import '../domain/entities/client_summary.dart';
import '../formatters/currency_formatter.dart';

class ClientSummaryCard extends StatelessWidget {
  final ClientSummary summary;
  
  const ClientSummaryCard({super.key, required this.summary});

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
            _buildDebtRow('عليّ', summary.onMe),
            _buildDebtRow('ليّ', summary.forMe),
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

### مثال: `calculate_client_debt.dart`
```dart
import '../entities/client_summary.dart';
import '../entities/transaction_summary.dart';

class CalculateClientDebt {
  static ClientSummary execute(List<DebtTransaction> transactions) {
    double forMe = 0;
    double onMe = 0;
    
    for (final transaction in transactions) {
      if (transaction.type == DebtType.forMe) {
        forMe += transaction.amount;
      } else {
        onMe += transaction.amount;
      }
    }
    
    return ClientSummary(
      forMe: forMe,
      onMe: onMe,
      totalTransactions: transactions.length,
    );
  }
}
```

---

## 6) فوائد التقسيم
- **سهولة القراءة**: كل ملف <= 200 سطر
- **سهولة الصيانة**: تعديل جزء معين دون التأثير على البقية
- **إعادة الاستخدام**: components يمكن استخدامها في أماكن أخرى
- **اختبار أسهل**: كل جزء يمكن اختباره بشكل مستقل
- **Git نظيف**: تغييرات صغيرة وواضحة في كل commit

---

## 7) متطلبات الأدوات
- **VS Code**: استخدم "Split Editor" لعرض ملفات متعددة
- **Flutter**: استخدم `flutter analyze` بعد كل تغيير
- **Git**: استخدم `git add -p` لمراجعة التغييرات قبل commit

---

## 8) خيار التنفيذ
- **خيار A (تدريجي)**: تقسيم ميزة واحدة في كل مرة (موصى به)
- **خيار B (سريع)**: تقسيم كل شيء دفعة واحدة (للخبراء فقط)

---

## 9) التالي
هل تريد أن نبدأ بخيار A وتقسيم Client Details أولاً؟ أم تفضل مراجعة الخطة أو تعديلها؟
