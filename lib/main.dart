import 'package:flutter/material.dart';

import 'screens/auth/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const QcashApp());
}

class QcashApp extends StatelessWidget {
  const QcashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Q Cash',
      debugShowCheckedModeBanner: false,
      theme: buildQcashTheme(),
      home: const WelcomeScreen(),
    );
  }
}
