import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/providers.dart';
import 'screens/home/app_home.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const QcashApp(),
    ),
  );
}

class QcashApp extends StatelessWidget {
  const QcashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q Cash',
      debugShowCheckedModeBanner: false,
      theme: buildQcashTheme(),
      home: const AppHome(),
    );
  }
}
