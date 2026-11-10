import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/advance.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
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

class DashboardScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    if (business == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: QcashColors.green)),
      );
    }

    final advances =
        ref.watch(advancesProvider(business.id)).value ?? const <Advance>[];
    final transactions = ref.watch(transactionsProvider(business.id)).value ??
        const <Transaction>[];
    final assessment = ref.watch(accessControllerProvider).assessment;

    final predictedRevenue = assessment?.predictedRevenueMinor ?? 0;
    final available = assessment?.recommendedAdvanceAmountMinor ?? 0;
    final currentRevenue = _currentRevenue(transactions);
    final accessed = _accessed(advances);
    final outstanding = _outstanding(advances);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Hi, ${business.businessName}',
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
              child: RefreshIndicator(
                color: QcashColors.green,
                onRefresh: () async {
                  ref.invalidate(advancesProvider(business.id));
                  ref.invalidate(transactionsProvider(business.id));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StatCard(
                        label: 'Available Early Access',
                        value: formatMinor(available),
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
                              child: StatCard(
                                label: 'Predicted Revenue',
                                value: formatMinor(predictedRevenue),
                                icon: Icons.auto_graph,
                                iconColor: QcashColors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Current Revenue',
                              value: formatMinor(currentRevenue),
                              icon: Icons.trending_up,
                              iconColor: QcashColors.navy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Accessed',
                              value: formatMinor(accessed),
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: QcashColors.purpleAlt,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Outstanding',
                              value: formatMinor(outstanding),
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
                      if (transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No transactions yet. Once your Paybill is connected, '
                            'transactions will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: QcashColors.textGray),
                          ),
                        )
                      else
                        ...transactions.take(3).map(
                              (t) => _transactionTile(t),
                            ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavBar(currentIndex: 0, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }

  int _currentRevenue(List<Transaction> transactions) {
    var total = 0;
    for (final t in transactions) {
      if (t.isInflow) total += t.amountMinor;
    }
    return total;
  }

  int _accessed(List<Advance> advances) {
    var total = 0;
    for (final a in advances) {
      if (a.disbursedAt != null) total += a.principalAmountMinor;
    }
    return total;
  }

  int _outstanding(List<Advance> advances) {
    var total = 0;
    for (final a in advances) {
      total += a.outstandingBalanceMinor;
    }
    return total;
  }

  Widget _transactionTile(Transaction t) {
    return TransactionTile(
      title: t.counterpartyName ?? (t.isInflow ? 'Paybill Deposit' : 'M-Pesa Outflow'),
      subtitle: formatDate(t.transactionTime),
      amount: formatMinorAmount(t.amountMinor),
      positive: t.isInflow,
    );
  }
}
