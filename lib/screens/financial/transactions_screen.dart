import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../access/access_revenue_screen.dart';
import '../account/profile_screen.dart';
import '../home/dashboard_screen.dart';
import 'repayment_screen.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _filter = 0;
  static const _filters = ['All', 'Income', 'Access', 'Repayment'];

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TransactionDetailsScreen()),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        break;
      case 1:
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
            const ScreenHeader(title: 'Transactions'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_filters.length, (i) {
                  final active = _filter == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? QcashColors.navy : QcashColors.iconBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? Colors.white : QcashColors.navy,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  TransactionTile(
                    title: 'Paybill Deposit',
                    subtitle: '3 Sep 2026',
                    amount: 'KES 3,200',
                    positive: true,
                    onTap: () => _openDetails(context),
                  ),
                  TransactionTile(
                    title: 'Early Access',
                    subtitle: '2 Sep 2026',
                    amount: 'KES 5,000',
                    positive: false,
                    onTap: () => _openDetails(context),
                  ),
                  TransactionTile(
                    title: 'Repayment',
                    subtitle: '1 Sep 2026',
                    amount: 'KES 1,000',
                    positive: false,
                    onTap: () => _openDetails(context),
                  ),
                  TransactionTile(
                    title: 'Paybill Deposit',
                    subtitle: '30 Aug 2026',
                    amount: 'KES 2,800',
                    positive: true,
                    onTap: () => _openDetails(context),
                  ),
                ],
              ),
            ),
            BottomNavBar(currentIndex: 1, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }
}
