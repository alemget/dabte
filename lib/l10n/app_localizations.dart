import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// عنوان التطبيق
  ///
  /// In ar, this message translates to:
  /// **'ديوني ماكس'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @clients.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get clients;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @searchClients.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن عميل...'**
  String get searchClients;

  /// No description provided for @noClients.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء'**
  String get noClients;

  /// No description provided for @noClientsDescription.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بإضافة عميل جديد'**
  String get noClientsDescription;

  /// No description provided for @addClient.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل'**
  String get addClient;

  /// No description provided for @editClient.
  ///
  /// In ar, this message translates to:
  /// **'تعديل عميل'**
  String get editClient;

  /// No description provided for @deleteClient.
  ///
  /// In ar, this message translates to:
  /// **'حذف عميل'**
  String get deleteClient;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteClient.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا العميل؟'**
  String get confirmDeleteClient;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @clientName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get clientName;

  /// No description provided for @clientNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم العميل'**
  String get clientNameHint;

  /// No description provided for @clientNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get clientNameRequired;

  /// No description provided for @phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phone;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get phoneHint;

  /// No description provided for @phoneOptional.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف (اختياري)'**
  String get phoneOptional;

  /// No description provided for @phoneContact.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف للتواصل'**
  String get phoneContact;

  /// No description provided for @address.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get addressHint;

  /// No description provided for @addressOptional.
  ///
  /// In ar, this message translates to:
  /// **'العنوان (اختياري)'**
  String get addressOptional;

  /// No description provided for @forMe.
  ///
  /// In ar, this message translates to:
  /// **'له'**
  String get forMe;

  /// No description provided for @onMe.
  ///
  /// In ar, this message translates to:
  /// **'عليه'**
  String get onMe;

  /// No description provided for @owes.
  ///
  /// In ar, this message translates to:
  /// **'عنده'**
  String get owes;

  /// No description provided for @net.
  ///
  /// In ar, this message translates to:
  /// **'الصافي'**
  String get net;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @totalForMe.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي له'**
  String get totalForMe;

  /// No description provided for @totalOnMe.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي عليه'**
  String get totalOnMe;

  /// No description provided for @totalNet.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الصافي'**
  String get totalNet;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @addDebt.
  ///
  /// In ar, this message translates to:
  /// **'إضافة دين جديد'**
  String get addDebt;

  /// No description provided for @editDebt.
  ///
  /// In ar, this message translates to:
  /// **'تعديل دين'**
  String get editDebt;

  /// No description provided for @newDebt.
  ///
  /// In ar, this message translates to:
  /// **'دين جديد'**
  String get newDebt;

  /// No description provided for @debtForMe.
  ///
  /// In ar, this message translates to:
  /// **'حقتي'**
  String get debtForMe;

  /// No description provided for @debtOnMe.
  ///
  /// In ar, this message translates to:
  /// **'حقه'**
  String get debtOnMe;

  /// No description provided for @amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get amount;

  /// No description provided for @amountRequired.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get amountRequired;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'العملة'**
  String get currency;

  /// No description provided for @client.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get client;

  /// No description provided for @selectClient.
  ///
  /// In ar, this message translates to:
  /// **'اختر العميل'**
  String get selectClient;

  /// No description provided for @chooseClient.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get chooseClient;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المعاملة (اختياري)'**
  String get details;

  /// No description provided for @note.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة (اختياري)'**
  String get note;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @change.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get change;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @noTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ديون'**
  String get noTransactions;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه المعاملة؟'**
  String get confirmDeleteTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In ar, this message translates to:
  /// **'حذف المعاملة'**
  String get deleteTransaction;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @general.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get general;

  /// No description provided for @security.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get security;

  /// No description provided for @accountSecurity.
  ///
  /// In ar, this message translates to:
  /// **'الحساب والأمان'**
  String get accountSecurity;

  /// No description provided for @customization.
  ///
  /// In ar, this message translates to:
  /// **'التخصيص'**
  String get customization;

  /// No description provided for @data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get data;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول'**
  String get about;

  /// No description provided for @information.
  ///
  /// In ar, this message translates to:
  /// **'معلومات'**
  String get information;

  /// No description provided for @personalInfo.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get personalInfo;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اسمك ومعلومات النشاط التجاري'**
  String get personalInfoSubtitle;

  /// No description provided for @businessName.
  ///
  /// In ar, this message translates to:
  /// **'اسم النشاط التجاري'**
  String get businessName;

  /// No description provided for @businessNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: متجر الإلكترونيات'**
  String get businessNameHint;

  /// No description provided for @ownerName.
  ///
  /// In ar, this message translates to:
  /// **'اسم صاحب النشاط'**
  String get ownerName;

  /// No description provided for @ownerNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسمك الكامل'**
  String get ownerNameHint;

  /// No description provided for @protectData.
  ///
  /// In ar, this message translates to:
  /// **'حماية بياناتك'**
  String get protectData;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get selectLanguage;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageChanged.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير اللغة'**
  String get languageChanged;

  /// No description provided for @restartApp.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إعادة تشغيل التطبيق'**
  String get restartApp;

  /// No description provided for @currencies.
  ///
  /// In ar, this message translates to:
  /// **'العملات'**
  String get currencies;

  /// No description provided for @manageCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'إدارة العملات'**
  String get manageCurrencies;

  /// No description provided for @manageExchangeRates.
  ///
  /// In ar, this message translates to:
  /// **'إدارة أسعار الصرف'**
  String get manageExchangeRates;

  /// No description provided for @addCurrency.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عملة'**
  String get addCurrency;

  /// No description provided for @editCurrency.
  ///
  /// In ar, this message translates to:
  /// **'تعديل عملة'**
  String get editCurrency;

  /// No description provided for @deleteCurrency.
  ///
  /// In ar, this message translates to:
  /// **'حذف عملة'**
  String get deleteCurrency;

  /// No description provided for @currencyName.
  ///
  /// In ar, this message translates to:
  /// **'اسم العملة'**
  String get currencyName;

  /// No description provided for @currencyCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز العملة'**
  String get currencyCode;

  /// No description provided for @currencySymbol.
  ///
  /// In ar, this message translates to:
  /// **'رمز العملة'**
  String get currencySymbol;

  /// No description provided for @exchangeRate.
  ///
  /// In ar, this message translates to:
  /// **'سعر الصرف'**
  String get exchangeRate;

  /// No description provided for @localCurrency.
  ///
  /// In ar, this message translates to:
  /// **'العملة المحلية'**
  String get localCurrency;

  /// No description provided for @setAsLocal.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كعملة محلية'**
  String get setAsLocal;

  /// No description provided for @activeCurrency.
  ///
  /// In ar, this message translates to:
  /// **'عملة نشطة'**
  String get activeCurrency;

  /// No description provided for @inactiveCurrency.
  ///
  /// In ar, this message translates to:
  /// **'عملة متوقفة'**
  String get inactiveCurrency;

  /// No description provided for @currencyInstructions.
  ///
  /// In ar, this message translates to:
  /// **'• اضغط مطولاً على أي عملة لجعلها العملة المحلية\\n• اضغط على العملة لتعديل سعر الصرف\\n• استخدم المفتاح لتفعيل/إيقاف العملة'**
  String get currencyInstructions;

  /// No description provided for @appLock.
  ///
  /// In ar, this message translates to:
  /// **'قفل التطبيق'**
  String get appLock;

  /// No description provided for @enableLock.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل القفل'**
  String get enableLock;

  /// No description provided for @disableLock.
  ///
  /// In ar, this message translates to:
  /// **'تعطيل القفل'**
  String get disableLock;

  /// No description provided for @unlockApp.
  ///
  /// In ar, this message translates to:
  /// **'فتح القفل'**
  String get unlockApp;

  /// No description provided for @biometricAuth.
  ///
  /// In ar, this message translates to:
  /// **'المصادقة البيومترية'**
  String get biometricAuth;

  /// No description provided for @useBiometric.
  ///
  /// In ar, this message translates to:
  /// **'استخدام البصمة أو الوجه'**
  String get useBiometric;

  /// No description provided for @fingerprintOrPin.
  ///
  /// In ar, this message translates to:
  /// **'البصمة أو رمز المرور'**
  String get fingerprintOrPin;

  /// No description provided for @confirmIdentity.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الهوية لتفعيل البصمة'**
  String get confirmIdentity;

  /// No description provided for @alertsReminders.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات وتذكيرات'**
  String get alertsReminders;

  /// No description provided for @backup.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backup;

  /// No description provided for @backupAndRestore.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي والاستعادة'**
  String get backupAndRestore;

  /// No description provided for @createBackup.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء نسخة احتياطية'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In ar, this message translates to:
  /// **'استعادة نسخة احتياطية'**
  String get restoreBackup;

  /// No description provided for @autoBackup.
  ///
  /// In ar, this message translates to:
  /// **'نسخ احتياطي تلقائي'**
  String get autoBackup;

  /// No description provided for @backupToGoogleDrive.
  ///
  /// In ar, this message translates to:
  /// **'نسخ احتياطي إلى Google Drive'**
  String get backupToGoogleDrive;

  /// No description provided for @localBackup.
  ///
  /// In ar, this message translates to:
  /// **'نسخ احتياطي محلي'**
  String get localBackup;

  /// No description provided for @lastBackup.
  ///
  /// In ar, this message translates to:
  /// **'آخر نسخة احتياطية'**
  String get lastBackup;

  /// No description provided for @never.
  ///
  /// In ar, this message translates to:
  /// **'أبداً'**
  String get never;

  /// No description provided for @backupSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء النسخة الاحتياطية بنجاح'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم استعادة البيانات بنجاح'**
  String get restoreSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء النسخة الاحتياطية'**
  String get backupFailed;

  /// No description provided for @restoreFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشلت الاستعادة'**
  String get restoreFailed;

  /// No description provided for @exportData.
  ///
  /// In ar, this message translates to:
  /// **'تصدير البيانات'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In ar, this message translates to:
  /// **'استيراد البيانات'**
  String get importData;

  /// No description provided for @clearAllData.
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع البيانات'**
  String get clearAllData;

  /// No description provided for @confirmClearData.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get confirmClearData;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @versionDeveloper.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار والمطور'**
  String get versionDeveloper;

  /// No description provided for @debtManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الديون'**
  String get debtManagement;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @versionNumber.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار 1.0.0'**
  String get versionNumber;

  /// No description provided for @developer.
  ///
  /// In ar, this message translates to:
  /// **'المطور'**
  String get developer;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get contactUs;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'قيم التطبيق'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get shareApp;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @debtReminders.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات الديون'**
  String get debtReminders;

  /// No description provided for @setReminder.
  ///
  /// In ar, this message translates to:
  /// **'تعيين تذكير'**
  String get setReminder;

  /// No description provided for @selectDebtForReminder.
  ///
  /// In ar, this message translates to:
  /// **'اختر دين للتذكير'**
  String get selectDebtForReminder;

  /// No description provided for @reminderSet.
  ///
  /// In ar, this message translates to:
  /// **'تم جدولة التذكير بنجاح'**
  String get reminderSet;

  /// No description provided for @reminderFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل جدولة التذكير'**
  String get reminderFailed;

  /// No description provided for @showConversions.
  ///
  /// In ar, this message translates to:
  /// **'عرض التحويلات'**
  String get showConversions;

  /// No description provided for @hideConversions.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء التحويلات'**
  String get hideConversions;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @allCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allCurrencies;

  /// No description provided for @allTypes.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allTypes;

  /// No description provided for @newest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In ar, this message translates to:
  /// **'الأقدم'**
  String get oldest;

  /// No description provided for @sortBy.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get sortBy;

  /// No description provided for @type.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get type;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجح'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @exchangeRateHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: 3.75'**
  String get exchangeRateHint;

  /// No description provided for @enterExchangeRate.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعر الصرف'**
  String get enterExchangeRate;

  /// No description provided for @enterValidNumberGreaterThanZero.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقماً صحيحاً أكبر من 0'**
  String get enterValidNumberGreaterThanZero;

  /// No description provided for @changeLocalCurrency.
  ///
  /// In ar, this message translates to:
  /// **'تغيير العملة المحلية'**
  String get changeLocalCurrency;

  /// No description provided for @confirmSetAsLocalCurrency.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تعيين هذه العملة كعملة محلية؟'**
  String get confirmSetAsLocalCurrency;

  /// No description provided for @chooseCurrencyFromList.
  ///
  /// In ar, this message translates to:
  /// **'اختر من القائمة'**
  String get chooseCurrencyFromList;

  /// No description provided for @perUnit.
  ///
  /// In ar, this message translates to:
  /// **'لكل وحدة'**
  String get perUnit;

  /// No description provided for @selectCurrencyFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة أولاً'**
  String get selectCurrencyFirst;

  /// No description provided for @noCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عملات'**
  String get noCurrencies;

  /// No description provided for @howToUse.
  ///
  /// In ar, this message translates to:
  /// **'كيفية الاستخدام'**
  String get howToUse;

  /// No description provided for @otherCurrencies.
  ///
  /// In ar, this message translates to:
  /// **'عملات أخرى'**
  String get otherCurrencies;

  /// No description provided for @cannotDeactivateCurrencyWithTransactions.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعطيل عملة مرتبطة بمعاملات'**
  String get cannotDeactivateCurrencyWithTransactions;

  /// No description provided for @local.
  ///
  /// In ar, this message translates to:
  /// **'محلية'**
  String get local;

  /// No description provided for @selectCurrency.
  ///
  /// In ar, this message translates to:
  /// **'اختر العملة'**
  String get selectCurrency;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @searchCurrencyOrCode.
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الرمز'**
  String get searchCurrencyOrCode;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @convertTo.
  ///
  /// In ar, this message translates to:
  /// **'التحويل إلى'**
  String get convertTo;

  /// No description provided for @currencySAR.
  ///
  /// In ar, this message translates to:
  /// **'ريال سعودي'**
  String get currencySAR;

  /// No description provided for @currencyAED.
  ///
  /// In ar, this message translates to:
  /// **'درهم إماراتي'**
  String get currencyAED;

  /// No description provided for @currencyKWD.
  ///
  /// In ar, this message translates to:
  /// **'دينار كويتي'**
  String get currencyKWD;

  /// No description provided for @currencyQAR.
  ///
  /// In ar, this message translates to:
  /// **'ريال قطري'**
  String get currencyQAR;

  /// No description provided for @currencyBHD.
  ///
  /// In ar, this message translates to:
  /// **'دينار بحريني'**
  String get currencyBHD;

  /// No description provided for @currencyOMR.
  ///
  /// In ar, this message translates to:
  /// **'ريال عماني'**
  String get currencyOMR;

  /// No description provided for @currencyYER.
  ///
  /// In ar, this message translates to:
  /// **'ريال يمني'**
  String get currencyYER;

  /// No description provided for @currencyEGP.
  ///
  /// In ar, this message translates to:
  /// **'جنيه مصري'**
  String get currencyEGP;

  /// No description provided for @currencyJOD.
  ///
  /// In ar, this message translates to:
  /// **'دينار أردني'**
  String get currencyJOD;

  /// No description provided for @currencyLBP.
  ///
  /// In ar, this message translates to:
  /// **'ليرة لبنانية'**
  String get currencyLBP;

  /// No description provided for @currencyIQD.
  ///
  /// In ar, this message translates to:
  /// **'دينار عراقي'**
  String get currencyIQD;

  /// No description provided for @currencySYP.
  ///
  /// In ar, this message translates to:
  /// **'ليرة سورية'**
  String get currencySYP;

  /// No description provided for @currencyLYD.
  ///
  /// In ar, this message translates to:
  /// **'دينار ليبي'**
  String get currencyLYD;

  /// No description provided for @currencyTND.
  ///
  /// In ar, this message translates to:
  /// **'دينار تونسي'**
  String get currencyTND;

  /// No description provided for @currencyDZD.
  ///
  /// In ar, this message translates to:
  /// **'دينار جزائري'**
  String get currencyDZD;

  /// No description provided for @currencyMAD.
  ///
  /// In ar, this message translates to:
  /// **'درهم مغربي'**
  String get currencyMAD;

  /// No description provided for @currencySDG.
  ///
  /// In ar, this message translates to:
  /// **'جنيه سوداني'**
  String get currencySDG;

  /// No description provided for @currencyUSD.
  ///
  /// In ar, this message translates to:
  /// **'دولار أمريكي'**
  String get currencyUSD;

  /// No description provided for @currencyEUR.
  ///
  /// In ar, this message translates to:
  /// **'يورو'**
  String get currencyEUR;

  /// No description provided for @currencyGBP.
  ///
  /// In ar, this message translates to:
  /// **'جنيه إسترليني'**
  String get currencyGBP;

  /// No description provided for @currencyCNY.
  ///
  /// In ar, this message translates to:
  /// **'يوان صيني'**
  String get currencyCNY;

  /// No description provided for @currencyJPY.
  ///
  /// In ar, this message translates to:
  /// **'ين ياباني'**
  String get currencyJPY;

  /// No description provided for @currencyTRY.
  ///
  /// In ar, this message translates to:
  /// **'ليرة تركية'**
  String get currencyTRY;

  /// No description provided for @currencyINR.
  ///
  /// In ar, this message translates to:
  /// **'روبية هندية'**
  String get currencyINR;

  /// No description provided for @currencyRUB.
  ///
  /// In ar, this message translates to:
  /// **'روبل روسي'**
  String get currencyRUB;

  /// No description provided for @currencyCAD.
  ///
  /// In ar, this message translates to:
  /// **'دولار كندي'**
  String get currencyCAD;

  /// No description provided for @currencyAUD.
  ///
  /// In ar, this message translates to:
  /// **'دولار أسترالي'**
  String get currencyAUD;

  /// No description provided for @currencyMYR.
  ///
  /// In ar, this message translates to:
  /// **'رينغيت ماليزي'**
  String get currencyMYR;

  /// No description provided for @currencyIDR.
  ///
  /// In ar, this message translates to:
  /// **'روبية إندونيسية'**
  String get currencyIDR;

  /// No description provided for @currencyGOLD24.
  ///
  /// In ar, this message translates to:
  /// **'ذهب عيار 24'**
  String get currencyGOLD24;

  /// No description provided for @currencyGOLD22.
  ///
  /// In ar, this message translates to:
  /// **'ذهب عيار 22'**
  String get currencyGOLD22;

  /// No description provided for @currencyGOLD21.
  ///
  /// In ar, this message translates to:
  /// **'ذهب عيار 21'**
  String get currencyGOLD21;

  /// No description provided for @currencyGOLD18.
  ///
  /// In ar, this message translates to:
  /// **'ذهب عيار 18'**
  String get currencyGOLD18;

  /// No description provided for @testNotification.
  ///
  /// In ar, this message translates to:
  /// **'تجربة الإشعار'**
  String get testNotification;

  /// No description provided for @testNotificationBody.
  ///
  /// In ar, this message translates to:
  /// **'هذا إشعار تجريبي للتأكد من عمل النظام'**
  String get testNotificationBody;

  /// No description provided for @testNotificationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال إشعار تجريبي'**
  String get testNotificationSent;

  /// No description provided for @testNotificationFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل إرسال الإشعار: '**
  String get testNotificationFailed;

  /// No description provided for @test.
  ///
  /// In ar, this message translates to:
  /// **'تجربة'**
  String get test;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
