import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../access/access_revenue_screen.dart';
import '../account/notifications_screen.dart';
import '../account/profile_screen.dart';
import '../financial/repayment_screen.dart';
import '../financial/transactions_screen.dart';
import '../revenue/revenue_overview_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
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
            ScreenHeader(
              title: 'Hi, Wanjiru General Store',
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: QcashColors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_none,
                      color: QcashColors.green),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StatCard(
                      label: 'Available Early Access',
                      value: 'KES 25,000',
                      isLarge: true,
                      highlight: true,
                      highlightColor: QcashColors.navy,
                      icon: Icons.bolt,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RevenueOverviewScreen()),
                            ),
                            child: const StatCard(
                              label: 'Predicted Revenue',
                              value: 'KES 45,000',
                              icon: Icons.auto_graph,
                              iconColor: QcashColors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: StatCard(
                            label: 'Current Revenue',
                            value: 'KES 38,000',
                            icon: Icons.trending_up,
                            iconColor: QcashColors.navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Accessed',
                            value: 'KES 5,000',
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: QcashColors.purpleAlt,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Outstanding',
                            value: 'KES 4,000',
                            icon: Icons.receipt_long_outlined,
                            iconColor: QcashColors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Access Revenue',
                      color: QcashColors.green,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AccessRevenueScreen()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionLabel('Recent Transactions'),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const TransactionsScreen()),
                          ),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: QcashColors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const TransactionTile(
                      title: 'Paybill Deposit',
                      subtitle: '3 Sep 2026',
                      amount: 'KES 3,200',
                      positive: true,
                    ),
                    const TransactionTile(
                      title: 'Early Access',
                      subtitle: '2 Sep 2026',
                      amount: 'KES 5,000',
                      positive: false,
                    ),
                    const TransactionTile(
                      title: 'Repayment',
                      subtitle: '1 Sep 2026',
                      amount: 'KES 1,000',
                      positive: false,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            BottomNavBar(currentIndex: 0, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }
}
