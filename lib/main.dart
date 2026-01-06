import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'providers/client_provider.dart';
import 'providers/language_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();

  final prefs = await SharedPreferences.getInstance();
  final seenIntro = prefs.getBool('seen_intro') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],

      // If seenIntro is true, show App (which handles Lock/Main).
      // If seenIntro is false, show IntroPage directly.
      // Note: IntroPage should probably navigate to App (or restart) when done.
      // But App() also has a MaterialApp. IntroPage also has a MaterialApp?
      // Let's check IntroPage. It returns ChangeNotifierProvider -> IntroPage shell.
      // IntroPage needs a MaterialApp if it's the root.
      // My implementation of IntroPage returned a ChangeNotifierProvider...
      // I should wrap IntroPage in a MaterialApp if it's the root here.
      // Or better: Let App handle the decision, like I thought earlier.
      // But passing 'seenIntro' to App is cleaner.
      child: App(seenIntro: seenIntro),
    ),
  );
}
