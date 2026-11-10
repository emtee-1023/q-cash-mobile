import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../access/access_revenue_screen.dart';
import '../account/profile_screen.dart';
import '../home/dashboard_screen.dart';
import 'repayment_screen.dart';
import 'transaction_details_screen.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  int _filter = 0;
  static const _filters = ['All', 'Income', 'Outflow'];

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
    final business = ref.watch(currentBusinessProvider);
    final all = business == null
        ? const <Transaction>[]
        : ref.watch(transactionsProvider(business.id)).value ??
            const <Transaction>[];

    final filtered = switch (_filter) {
      1 => all.where((t) => t.isInflow).toList(),
      2 => all.where((t) => !t.isInflow).toList(),
      _ => all,
    };

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
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(color: QcashColors.textGray),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, color: QcashColors.divider),
                      itemBuilder: (context, i) => _tile(context, filtered[i]),
                    ),
            ),
            BottomNavBar(currentIndex: 1, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, Transaction t) {
    return TransactionTile(
      title: t.counterpartyName ??
          (t.isInflow ? 'Paybill Deposit' : (t.transactionType ?? 'Outflow')),
      subtitle: formatDate(t.transactionTime, withTime: true),
      amount: formatMinorAmount(t.amountMinor),
      positive: t.isInflow,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TransactionDetailsScreen(transaction: t),
        ),
      ),
    );
  }
}
