import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/screen_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Notifications', showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: const [
                  _NotificationTile(
                    icon: Icons.auto_graph,
                    color: QcashColors.green,
                    title: 'Revenue prediction updated',
                    time: '2h ago',
                  ),
                  _NotificationTile(
                    icon: Icons.check_circle_outline,
                    color: QcashColors.green,
                    title: 'Early access approved',
                    time: '1d ago',
                  ),
                  _NotificationTile(
                    icon: Icons.account_balance_wallet_outlined,
                    color: QcashColors.navy,
                    title: 'Early access received',
                    time: '1d ago',
                  ),
                  _NotificationTile(
                    icon: Icons.swap_horiz,
                    color: QcashColors.orange,
                    title: 'Repayment recorded',
                    time: '3d ago',
                  ),
                  _NotificationTile(
                    icon: Icons.link_off,
                    color: QcashColors.pink,
                    title: 'Account connection issue',
                    time: '5d ago',
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: QcashColors.navy,
              ),
            ),
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, color: QcashColors.textGray),
          ),
        ],
      ),
    );
  }
}
