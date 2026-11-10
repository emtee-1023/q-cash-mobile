import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/business.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/business_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../access/access_revenue_screen.dart';
import '../financial/repayment_screen.dart';
import '../financial/transactions_screen.dart';
import '../home/dashboard_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TransactionsScreen()),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccessRevenueScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RepaymentScreen()),
        );
        break;
      case 4:
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    final business = ref.watch(currentBusinessProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Profile'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: QcashColors.green,
                        child: Text(
                          _initials(user?.name ?? ''),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        user?.name ?? 'Loading…',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: QcashColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InfoCard(
                      children: [
                        KeyValueRow(label: 'Name', value: user?.name ?? '—'),
                        KeyValueRow(
                            label: 'Phone', value: user?.phoneNumber ?? '—'),
                        KeyValueRow(label: 'Email', value: user?.email ?? '—'),
                        KeyValueRow(
                          label: 'Business Name',
                          value: business?.businessName ?? '—',
                        ),
                        KeyValueRow(
                          label: 'Business Info',
                          value: _businessInfo(business),
                        ),
                        KeyValueRow(
                          label: 'Account Status',
                          value: business?.status ?? '—',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: QcashColors.navy,
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: QcashColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Settings', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            BottomNavBar(currentIndex: 4, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'Q';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _businessInfo(Business? business) {
    if (business == null) return '—';
    final parts = [business.businessCategory, business.town, business.county]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.isEmpty ? '—' : parts.join(' / ');
  }
}
