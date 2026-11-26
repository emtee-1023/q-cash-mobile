import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_providers.dart';
import '../../core/providers/theme_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';
import 'help_support_screen.dart';
import 'manage_businesses_screen.dart';
import 'notifications_screen.dart';
import 'personal_information_screen.dart';
import 'security_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Settings', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _SettingsRow(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PersonalInformationScreen(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.storefront_outlined,
                    title: 'Manage Businesses',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManageBusinessesScreen(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.lock_outline,
                    title: 'Security',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SecurityScreen()),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    value: _themeModeLabel(themeMode),
                    onTap: () => _showThemeSheet(context, ref),
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  _SettingsRow(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: const Color(0xFFE53935),
                    onTap: () => _logout(ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
  }

  Future<void> _showThemeSheet(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.qc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final mode = sheetRef.watch(themeModeProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.qc.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose how QCash looks.',
                      style: TextStyle(fontSize: 13, color: context.qc.muted),
                    ),
                    const SizedBox(height: 12),
                    _ThemeModeOption(
                      label: 'System default',
                      description: 'Follow your device setting',
                      icon: Icons.brightness_auto_outlined,
                      selected: mode == ThemeMode.system,
                      onTap: () => _selectTheme(
                        sheetContext,
                        sheetRef,
                        ThemeMode.system,
                      ),
                    ),
                    _ThemeModeOption(
                      label: 'Light',
                      description: 'Always use light mode',
                      icon: Icons.light_mode_outlined,
                      selected: mode == ThemeMode.light,
                      onTap: () =>
                          _selectTheme(sheetContext, sheetRef, ThemeMode.light),
                    ),
                    _ThemeModeOption(
                      label: 'Dark',
                      description: 'Always use dark mode',
                      icon: Icons.dark_mode_outlined,
                      selected: mode == ThemeMode.dark,
                      onTap: () =>
                          _selectTheme(sheetContext, sheetRef, ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _selectTheme(BuildContext context, WidgetRef ref, ThemeMode mode) {
    ref.read(themeModeProvider.notifier).setMode(mode);
    Navigator.of(context).pop();
  }

  Future<void> _logout(WidgetRef ref) async {
    await ref.read(authControllerProvider.notifier).logout();
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.qc.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.qc.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: foreground),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: foreground,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: TextStyle(fontSize: 13, color: context.qc.muted),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? QcashColors.green.withValues(alpha: 0.08)
                : context.qc.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? QcashColors.green.withValues(alpha: 0.5)
                  : context.qc.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? QcashColors.green : context.qc.muted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.qc.text,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: context.qc.muted),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: QcashColors.green,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
