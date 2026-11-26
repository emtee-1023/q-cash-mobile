import 'package:flutter/material.dart';

/// Brand colors that stay the same in both light and dark mode.
class QcashColors {
  QcashColors._();

  static const Color green = Color(0xFF1DAB87);
  static const Color navy = Color(0xFF1D3A70);
  static const Color navyDark = Color(0xFF203C71);
  static const Color orange = Color(0xFFFB923C);
  static const Color purple = Color(0xFFAB92F0);
  static const Color pink = Color(0xFFFFB9AA);
  static const Color purpleAlt = Color(0xFF7B61FF);
}

/// Surface and text colors that change with the active brightness.
@immutable
class QcashPalette extends ThemeExtension<QcashPalette> {
  const QcashPalette({
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.divider,
    required this.text,
    required this.muted,
  });

  static const light = QcashPalette(
    background: Colors.white,
    surface: Colors.white,
    card: Color(0xFFF9FAFB),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFF3F4F6),
    text: QcashColors.navy,
    muted: Color(0xFF6B7280),
  );

  static const dark = QcashPalette(
    background: Color(0xFF0B1220),
    surface: Color(0xFF111A2A),
    card: Color(0xFF182234),
    border: Color(0xFF2B3850),
    divider: Color(0xFF1F2A3D),
    text: Color(0xFFEAF0FA),
    muted: Color(0xFF9AA7BD),
  );

  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color divider;
  final Color text;
  final Color muted;

  @override
  QcashPalette copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? border,
    Color? divider,
    Color? text,
    Color? muted,
  }) {
    return QcashPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      text: text ?? this.text,
      muted: muted ?? this.muted,
    );
  }

  @override
  QcashPalette lerp(ThemeExtension<QcashPalette>? other, double t) {
    if (other is! QcashPalette) return this;
    return QcashPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

extension QcashThemeContext on BuildContext {
  QcashPalette get qc {
    final theme = Theme.of(this);
    return theme.extension<QcashPalette>() ??
        (theme.brightness == Brightness.dark
            ? QcashPalette.dark
            : QcashPalette.light);
  }
}

ThemeData buildQcashTheme() => _buildQcashTheme(Brightness.light);

ThemeData buildQcashDarkTheme() => _buildQcashTheme(Brightness.dark);

ThemeData _buildQcashTheme(Brightness brightness) {
  final palette = brightness == Brightness.dark
      ? QcashPalette.dark
      : QcashPalette.light;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: QcashColors.green,
      brightness: brightness,
      primary: QcashColors.navy,
      secondary: QcashColors.green,
      surface: palette.card,
    ),
    scaffoldBackgroundColor: palette.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.text,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: palette.text,
      displayColor: palette.text,
    ),
    iconTheme: IconThemeData(color: palette.text),
    dividerColor: palette.divider,
    dividerTheme: DividerThemeData(color: palette.divider),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: palette.surface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.green, width: 1.5),
      ),
      hintStyle: TextStyle(color: palette.muted),
    ),
    extensions: [palette],
  );
}
