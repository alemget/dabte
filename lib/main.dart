import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'providers/client_provider.dart';
import 'providers/language_provider.dart';

Future<void> main() async {
  // تهيئة خدمات الخلفية (بدون انتظار لتسريع الفتح)
  // تهيئة خدمة الإشعارات (بدون انتظار لتسريع الفتح)
  await bootstrap();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const App(),
    ),
  );
}
