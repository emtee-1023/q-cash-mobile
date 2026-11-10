import 'package:flutter/material.dart';

class QcashColors {
  QcashColors._();

  static const Color green = Color(0xFF1DAB87);
  static const Color navy = Color(0xFF1D3A70);
  static const Color navyDark = Color(0xFF203C71);
  static const Color background = Colors.white;
  static const Color iconBg = Color(0xFFF9FAFB);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color textGray = Color(0xFF6B7280);
  static const Color orange = Color(0xFFFB923C);
  static const Color purple = Color(0xFFAB92F0);
  static const Color pink = Color(0xFFFFB9AA);
  static const Color purpleAlt = Color(0xFF7B61FF);
}

ThemeData buildQcashTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: QcashColors.green,
      primary: QcashColors.navy,
      secondary: QcashColors.green,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: QcashColors.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: QcashColors.navy,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: QcashColors.navy,
      displayColor: QcashColors.navy,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: QcashColors.iconBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.green, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),
  );
}
