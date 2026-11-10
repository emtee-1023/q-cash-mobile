import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../access/access_revenue_screen.dart';
import '../account/profile_screen.dart';
import '../home/dashboard_screen.dart';
import 'repayment_details_screen.dart';
import 'transactions_screen.dart';

class RepaymentScreen extends StatelessWidget {
  const RepaymentScreen({super.key});

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
        break;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Repayment'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: StatCard(label: 'Outstanding', value: 'KES 4,000'),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCard(label: 'Repaid', value: 'KES 1,000'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Repayment Progress'),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 0.25,
                        minHeight: 12,
                        backgroundColor: QcashColors.divider,
                        valueColor: AlwaysStoppedAnimation(QcashColors.green),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '25% repaid',
                      style: TextStyle(
                        fontSize: 13,
                        color: QcashColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const InfoCard(
                      children: [
                        KeyValueRow(
                          label: 'Next Expected Repayment',
                          value: 'KES 500',
                        ),
                        KeyValueRow(label: 'Due Date', value: '10 Sep 2026'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Repayment History'),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RepaymentDetailsScreen(),
                        ),
                      ),
                      child: const TransactionTile(
                        title: 'Automatic deduction',
                        subtitle: '1 Sep 2026',
                        amount: 'KES 1,000',
                        positive: false,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            BottomNavBar(currentIndex: 3, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }
}
