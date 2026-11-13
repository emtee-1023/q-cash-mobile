import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/advance.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../access/access_revenue_screen.dart';
import '../account/profile_screen.dart';
import '../home/dashboard_screen.dart';
import 'repay_screen.dart';
import 'repayment_details_screen.dart';
import 'transactions_screen.dart';

class RepaymentScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    final advances = business == null
        ? const <Advance>[]
        : ref.watch(advancesProvider(business.id)).value ??
            const <Advance>[];

    final outstanding = advances.fold<int>(0, (s, a) => s + a.outstandingBalanceMinor);
    final repaid = advances.fold<int>(0, (s, a) => s + a.amountRepaidMinor);
    final total = outstanding + repaid;
    final progress = total == 0 ? 0.0 : repaid / total;

    DateTime? nextDue;
    final now = DateTime.now();
    for (final a in advances) {
      if (a.dueAt != null && a.dueAt!.isAfter(now)) {
        if (nextDue == null || a.dueAt!.isBefore(nextDue)) nextDue = a.dueAt;
      }
    }

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
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Outstanding',
                            value: formatMinor(outstanding),
                            icon: Icons.receipt_long_outlined,
                            iconColor: QcashColors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Repaid',
                            value: formatMinor(repaid),
                            icon: Icons.check_circle_outline,
                            iconColor: QcashColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Repayment Progress'),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: QcashColors.divider,
                        valueColor: const AlwaysStoppedAnimation(QcashColors.green),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).round()}% repaid',
                      style: const TextStyle(
                        fontSize: 13,
                        color: QcashColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InfoCard(
                      children: [
                        KeyValueRow(
                          label: 'Next Expected Repayment',
                          value: nextDue == null ? '—' : formatDate(nextDue),
                        ),
                        KeyValueRow(
                          label: 'Active Advances',
                          value: '${advances.length}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Your Advances'),
                    if (advances.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No advances yet. Access revenue to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: QcashColors.textGray),
                        ),
                      )
                    else ...[
                      PrimaryButton(
                        label: 'Make a Repayment',
                        color: QcashColors.green,
                        onPressed: outstanding > 0
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const RepayScreen()),
                                )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ...advances.map(
                        (a) => TransactionTile(
                          title: 'Advance ${a.publicId}',
                          subtitle: 'Due ${formatDate(a.dueAt)}',
                          amount: formatMinorAmount(a.outstandingBalanceMinor),
                          positive: false,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RepaymentDetailsScreen(advance: a),
                            ),
                          ),
                        ),
                      ),
                    ],
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
