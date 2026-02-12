# دليل إعداد Google Cloud للنشر (Production)

لجعل تطبيقك "رسمي" والسماح لأي بريد إلكتروني باستخدام النسخ الاحتياطي دون إضافته يدوياً، يجب عليك **نشر التطبيق** في Google Cloud Console.

### 1. تغيير حالة النشر (Publishing Status)

المشكلة الحالية هي أن التطبيق في وضع **Testing**، مما يتطلب إضافة كل بريد إلكتروني يدوياً. الحل هو تحويله إلى **In production**.

1. اذهب إلى [Google Cloud Console - OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent).
2. تأكد من اختيار مشروعك `debt-max` (أو `diomax` حسب التسمية).
3. تحت قسم **Publishing status** (حالة النشر)، اضغط على زر **PUBLISH APP** (نشر التطبيق).
   - قد يطلب منك تأكيداً، وافق عليه.
4. الآن سيصبح التطبيق متاحاً لأي شخص يملك حساب Google.

### 2. ملاحظة هامة بخصوص "التحقق" (Verification)

بما أنك تستخدم صلاحية `drive.file` (الوصول لملفات Google Drive)، فإن Google تعتبر هذه الصلاحية "حساسة" (Sensitive Scope).

*   **بعد النشر**: سيتمكن المستخدمون من الدخول، ولكن قد تظهر لهم شاشة تحذيرية تقول **"Google hasn't verified this app"** (لم تتحقق Google من هذا التطبيق).
*   **لتجاوز التحذير**: المستخدم يحتاج للضغط على "Advanced" ثم "Go to [App Name] (unsafe)".
*   **لإزالة التحذير نهائياً**: يجب عليك تقديم طلب "Verification" لشركة Google، وهذا يتطلب:
    *   رابط لسياسة الخصوصية (Privacy Policy) في التطبيق.
    *   فيديو يوضح كيفية استخدام التطبيق للصلاحية.
    *   (غالباً للاستخدام الشخصي أو المحدود، يمكن تجاهل هذا والاكتفاء بشاشة التحذير، ولكن لجعله "رسمي 100%" يجب تقديم الطلب).

### 3. التأكد من بصمة SHA-1

لضمان عمل تسجيل الدخول، تأكد من إضافة بصمة SHA-1 الخاصة بجهازك (وخاصة نسخة الـ Release عند رفع التطبيق للمتجر) في [Google Cloud Credentials](https://console.cloud.google.com/apis/credentials).

بما أن الكود السابق لم يظهر البصمة، يمكنك تجربة هذا الأمر في التيرمنال داخل Android Studio للتأكد:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "C:\Users\1\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

انسخ الـ **SHA1** وضيفه في قسم Credentials -> Android Client.

### 4. ملاحظة بخصوص الكود

لاحظت أن كود `drive_backup_service.dart` معطل (داخل تعليق `/* ... */`). تأكد من تفعيله (إزالة علامات التعليق) ليعمل الربط في التطبيق.
