import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers/auth_providers.dart';
import 'core/providers/providers.dart';
import 'core/providers/theme_providers.dart';
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

final _navigatorKey = GlobalKey<NavigatorState>();

class QcashApp extends ConsumerStatefulWidget {
  const QcashApp({super.key});

  @override
  ConsumerState<QcashApp> createState() => _QcashAppState();
}

class _QcashAppState extends ConsumerState<QcashApp> {
  StreamSubscription<void>? _unauthorizedSubscription;

  @override
  void initState() {
    super.initState();
    _unauthorizedSubscription =
        ref.read(apiClientProvider).onUnauthorized.listen((_) {
      ref.read(authControllerProvider.notifier).expireSession();
    });
  }

  @override
  void dispose() {
    _unauthorizedSubscription?.cancel();
    super.dispose();
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppHome(showSplash: false)),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (previous != null &&
          previous.isAuthenticated &&
          !next.isAuthenticated) {
        _redirectToLogin();
      }
    });

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'QCash',
      debugShowCheckedModeBanner: false,
      theme: buildQcashTheme(),
      darkTheme: buildQcashDarkTheme(),
      themeMode: ref.watch(themeModeProvider),
      home: const AppHome(),
    );
  }
}
