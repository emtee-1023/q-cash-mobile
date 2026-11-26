import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/providers/providers.dart';
import 'package:mobile/core/providers/theme_providers.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  ProviderContainer containerFor(SharedPreferences prefs) {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('defaults to following the system', () async {
    final container = containerFor(await prefsWith({}));

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('restores a persisted mode', () async {
    final container = containerFor(
      await prefsWith({'qcash.theme_mode': 'dark'}),
    );

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('persists a selected mode', () async {
    final prefs = await prefsWith({});
    final container = containerFor(prefs);

    container.read(themeModeProvider.notifier).setMode(ThemeMode.light);

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(prefs.getString('qcash.theme_mode'), 'light');
  });

  test('builds a dark theme with the dark palette', () {
    final theme = buildQcashDarkTheme();

    expect(theme.brightness, Brightness.dark);
    expect(theme.extension<QcashPalette>(), QcashPalette.dark);
  });
}
