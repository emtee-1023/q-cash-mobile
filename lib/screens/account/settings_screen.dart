import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Settings', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const _SettingsRow(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                  ),
                  const _SettingsRow(
                    icon: Icons.storefront_outlined,
                    title: 'Business Information',
                  ),
                  const _SettingsRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'M-Pesa Account',
                  ),
                  const _SettingsRow(
                    icon: Icons.lock_outline,
                    title: 'Security',
                  ),
                  const _SettingsRow(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                  ),
                  _SettingsRow(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                    ),
                  ),
                  const Divider(height: 24),
                  const _SettingsRow(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Color(0xFFE53935),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.color = QcashColors.navy,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
                color: QcashColors.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: QcashColors.textGray),
          ],
        ),
      ),
    );
  }
}
