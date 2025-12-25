// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Debt Max';

  @override
  String get home => 'Home';

  @override
  String get clients => 'Clients';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get reportsOverview => 'Overview';

  @override
  String get reportsByCurrency => 'By Currency';

  @override
  String get reportsTopClients => 'Top Clients';

  @override
  String get reportsCurrencies => 'Currencies';

  @override
  String get reportsLastActivity => 'Last Activity';

  @override
  String get reportsNoData => 'No data to show yet';

  @override
  String get searchClients => 'Search for a client...';

  @override
  String get noClients => 'No clients';

  @override
  String get noClientsDescription => 'Start by adding a new client';

  @override
  String get addClient => 'Add Client';

  @override
  String get editClient => 'Edit Client';

  @override
  String get deleteClient => 'Delete Client';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteClient => 'Do you want to delete this client?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get clientName => 'Client Name';

  @override
  String get clientNameHint => 'Enter client name';

  @override
  String get clientNameRequired => 'Name is required';

  @override
  String get phone => 'Phone Number';

  @override
  String get phoneHint => 'Optional';

  @override
  String get phoneOptional => 'Phone Number (optional)';

  @override
  String get phoneContact => 'Contact Phone Number';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Optional';

  @override
  String get addressOptional => 'Address (optional)';

  @override
  String get forMe => 'They Owe';

  @override
  String get onMe => 'I Owe';

  @override
  String get owes => 'Owes';

  @override
  String get net => 'Net';

  @override
  String get total => 'Total';

  @override
  String get totalForMe => 'Total They Owe';

  @override
  String get totalOnMe => 'Total I Owe';

  @override
  String get totalNet => 'Total Net';

  @override
  String get all => 'All';

  @override
  String get addDebt => 'Add New Debt';

  @override
  String get editDebt => 'Edit Debt';

  @override
  String get newDebt => 'New Debt';

  @override
  String get debtForMe => 'They owe me';

  @override
  String get debtOnMe => 'I owe them';

  @override
  String get amount => 'Amount';

  @override
  String get amountRequired => 'Required';

  @override
  String get currency => 'Currency';

  @override
  String get client => 'Client';

  @override
  String get selectClient => 'Select Client';

  @override
  String get chooseClient => 'Choose';

  @override
  String get details => 'Transaction details (optional)';

  @override
  String get note => 'Note (optional)';

  @override
  String get date => 'Date';

  @override
  String get change => 'Change';

  @override
  String get add => 'Add';

  @override
  String get noTransactions => 'No debts';

  @override
  String get confirmDeleteTransaction =>
      'Do you want to delete this transaction?';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get general => 'General';

  @override
  String get security => 'Security';

  @override
  String get accountSecurity => 'Account & Security';

  @override
  String get customization => 'Customization';

  @override
  String get data => 'Data';

  @override
  String get about => 'About';

  @override
  String get information => 'Information';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoSubtitle => 'Your name and business information';

  @override
  String get businessName => 'Business Name';

  @override
  String get businessNameHint => 'Example: Electronics Store';

  @override
  String get ownerName => 'Owner Name';

  @override
  String get ownerNameHint => 'Your full name';

  @override
  String get protectData => 'Protect your data';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get restartApp => 'App will restart';

  @override
  String get currencies => 'Currencies';

  @override
  String get manageCurrencies => 'Manage Currencies';

  @override
  String get manageExchangeRates => 'Manage Exchange Rates';

  @override
  String get addCurrency => 'Add Currency';

  @override
  String get editCurrency => 'Edit Currency';

  @override
  String get deleteCurrency => 'Delete Currency';

  @override
  String get currencyName => 'Currency Name';

  @override
  String get currencyCode => 'Currency Code';

  @override
  String get currencySymbol => 'Currency Symbol';

  @override
  String get exchangeRate => 'Exchange Rate';

  @override
  String get localCurrency => 'Local Currency';

  @override
  String get setAsLocal => 'Set as Local';

  @override
  String get activeCurrency => 'Active Currency';

  @override
  String get inactiveCurrency => 'Inactive Currency';

  @override
  String get currencyInstructions =>
      '• Long press any currency to set it as local\\n• Tap currency to edit exchange rate\\n• Use the switch to activate/deactivate currency';

  @override
  String get appLock => 'App Lock';

  @override
  String get enableLock => 'Enable Lock';

  @override
  String get disableLock => 'Disable Lock';

  @override
  String get unlockApp => 'Unlock';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get useBiometric => 'Use fingerprint or face';

  @override
  String get fingerprintOrPin => 'Fingerprint or PIN';

  @override
  String get confirmIdentity => 'Confirm identity to enable biometric';

  @override
  String get alertsReminders => 'Alerts & Reminders';

  @override
  String get backup => 'Backup';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get autoBackup => 'Auto Backup';

  @override
  String get backupToGoogleDrive => 'Backup to Google Drive';

  @override
  String get localBackup => 'Local Backup';

  @override
  String get lastBackup => 'Last Backup';

  @override
  String get never => 'Never';

  @override
  String get backupSuccess => 'Backup created successfully';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get confirmClearData =>
      'Do you want to clear all data? This action cannot be undone.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get versionDeveloper => 'Version & Developer';

  @override
  String get debtManagement => 'Debt Management';

  @override
  String get version => 'Version';

  @override
  String get versionNumber => 'Version 1.0.0';

  @override
  String get developer => 'Developer';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get notifications => 'Notifications';

  @override
  String get debtReminders => 'Debt Reminders';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get selectDebtForReminder => 'Select debt for reminder';

  @override
  String get reminderSet => 'Reminder scheduled successfully';

  @override
  String get reminderFailed => 'Failed to schedule reminder';

  @override
  String get showConversions => 'Show Conversions';

  @override
  String get hideConversions => 'Hide Conversions';

  @override
  String get filter => 'Filter';

  @override
  String get allCurrencies => 'All';

  @override
  String get allTypes => 'All';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get sortBy => 'Sort By';

  @override
  String get type => 'Type';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get loading => 'Loading...';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get confirm => 'Confirm';

  @override
  String get exchangeRateHint => 'Ex: 3.75';

  @override
  String get enterExchangeRate => 'Enter Exchange Rate';

  @override
  String get enterValidNumberGreaterThanZero => 'Enter valid number > 0';

  @override
  String get changeLocalCurrency => 'Change Local Currency';

  @override
  String get confirmSetAsLocalCurrency =>
      'Do you want to set this currency as local?';

  @override
  String get chooseCurrencyFromList => 'Choose from list';

  @override
  String get perUnit => 'Per Unit';

  @override
  String get selectCurrencyFirst => 'Select currency first';

  @override
  String get noCurrencies => 'No currencies found';

  @override
  String get howToUse => 'How to use';

  @override
  String get otherCurrencies => 'Other Currencies';

  @override
  String get cannotDeactivateCurrencyWithTransactions =>
      'Cannot deactivate currency with existing transactions';

  @override
  String get local => 'Local';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get search => 'Search';

  @override
  String get searchCurrencyOrCode => 'Search by name or code';

  @override
  String get noResults => 'No results found';

  @override
  String get convertTo => 'Convert to';

  @override
  String get currencySAR => 'Saudi Riyal';

  @override
  String get currencyAED => 'UAE Dirham';

  @override
  String get currencyKWD => 'Kuwaiti Dinar';

  @override
  String get currencyQAR => 'Qatari Riyal';

  @override
  String get currencyBHD => 'Bahraini Dinar';

  @override
  String get currencyOMR => 'Omani Rial';

  @override
  String get currencyYER => 'Yemeni Rial';

  @override
  String get currencyEGP => 'Egyptian Pound';

  @override
  String get currencyJOD => 'Jordanian Dinar';

  @override
  String get currencyLBP => 'Lebanese Lira';

  @override
  String get currencyIQD => 'Iraqi Dinar';

  @override
  String get currencySYP => 'Syrian Lira';

  @override
  String get currencyLYD => 'Libyan Dinar';

  @override
  String get currencyTND => 'Tunisian Dinar';

  @override
  String get currencyDZD => 'Algerian Dinar';

  @override
  String get currencyMAD => 'Moroccan Dirham';

  @override
  String get currencySDG => 'Sudanese Pound';

  @override
  String get currencyUSD => 'US Dollar';

  @override
  String get currencyEUR => 'Euro';

  @override
  String get currencyGBP => 'British Pound';

  @override
  String get currencyCNY => 'Chinese Yuan';

  @override
  String get currencyJPY => 'Japanese Yen';

  @override
  String get currencyTRY => 'Turkish Lira';

  @override
  String get currencyINR => 'Indian Rupee';

  @override
  String get currencyRUB => 'Russian Ruble';

  @override
  String get currencyCAD => 'Canadian Dollar';

  @override
  String get currencyAUD => 'Australian Dollar';

  @override
  String get currencyMYR => 'Malaysian Ringgit';

  @override
  String get currencyIDR => 'Indonesian Rupiah';

  @override
  String get currencyGOLD24 => 'Gold 24K';

  @override
  String get currencyGOLD22 => 'Gold 22K';

  @override
  String get currencyGOLD21 => 'Gold 21K';

  @override
  String get currencyGOLD18 => 'Gold 18K';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotificationBody =>
      'This is a test notification to verify the system';

  @override
  String get testNotificationSent => 'Test notification sent';

  @override
  String get testNotificationFailed => 'Failed to send notification: ';

  @override
  String get test => 'Test';
}
