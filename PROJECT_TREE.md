# Project Tree ( diomax /  ديوماكس)

## Root

```text
Dabdt/
├─ android/
├─ assets/
├─ ios/
├─ lib/
├─ test/
├─ web/
├─ pubspec.yaml
├─ pubspec.lock
├─ README.md
└─ ...
```

## lib/

```text
lib/
├─ app/
│  ├─ app.dart
│  ├─ bootstrap.dart
│  └─ src/
├─ data/
│  ├─ currency_data.dart
│  ├─ debt_database.dart
│  └─ repositories/
│     └─ client_repository.dart
├─ features/
│  ├─ backup/
│  │  ├─ data/
│  │  ├─ domain/
│  │  └─ presentation/
│  └─ reports/
│     ├─ data/
│     ├─ domain/
│     └─ presentation/
├─ l10n/
│  ├─ app_ar.arb
│  ├─ app_en.arb
│  ├─ app_localizations.dart
│  ├─ app_localizations_ar.dart
│  └─ app_localizations_en.dart
├─ models/
│  ├─ app_currency.dart
│  ├─ client.dart
│  └─ transaction.dart
├─ providers/
│  ├─ client_provider.dart
│  └─ language_provider.dart
├─ services/
│  ├─ contact_picker_service.dart
│  ├─ currency_settings_service.dart
│  ├─ invoice_service.dart
│  ├─ notification_service.dart
│  └─ whatsapp_service.dart
├─ ui/
│  ├─ lock_screen.dart
│  ├─ main_screen.dart
│  ├─ splash_screen.dart
│  ├─ clients/
│  ├─ intro/
│  ├─ reports/
│  ├─ settings/
│  └─ widgets/
├─ utils/
│  ├─ currency_utils.dart
│  └─ encryption_helper.dart
└─ main.dart
```

## lib/ui/intro/ (Onboarding / شاشة البداية)

```text
lib/ui/intro/
├─ intro_page.dart
├─ intro_provider.dart
├─ intro_shell.dart
├─ pages/
│  ├─ welcome_screen.dart
│  ├─ verse_intro_page.dart
│  ├─ name_setup_page.dart
│  ├─ currency_setup_page.dart
│  ├─ profile_setup_page.dart
│  ├─ backup_setup_page.dart
│  ├─ verse/
│  │  └─ verse_page.dart
│  ├─ name/
│  │  └─ name_page.dart
│  └─ currency/
│     └─ currency_page.dart
├─ theme/
│  └─ intro_theme.dart
└─ widgets/
   ├─ page_indicator.dart
   └─ swipe_hint.dart
```

## lib/ui/ (UI layer)

```text
lib/ui/
├─ splash_screen.dart
├─ main_screen.dart
├─ lock_screen.dart
├─ clients/
│  ├─ clients_list/
│  ├─ client_details/
│  ├─ add_edit_client/
│  ├─ add_edit_transaction/
│  ├─ components/
│  ├─ utils/
│  └─ widgets/
├─ intro/  (see section above)
├─ reports/
├─ settings/
└─ widgets/
   ├─ currency_display_helper.dart
   ├─ gold_bar_icon.dart
   └─ money_amount.dart
```
