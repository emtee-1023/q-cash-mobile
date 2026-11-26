import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

/// The user's preferred theme mode, persisted across launches and defaulting
/// to following the system setting.
class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'qcash.theme_mode';

  @override
  ThemeMode build() {
    final stored = ref.read(sharedPreferencesProvider).getString(_key);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setMode(ThemeMode mode) {
    ref.read(sharedPreferencesProvider).setString(_key, mode.name);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
