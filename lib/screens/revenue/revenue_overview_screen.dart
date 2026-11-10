import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class RevenueOverviewScreen extends ConsumerWidget {
  const RevenueOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    final assessment = ref.watch(accessControllerProvider).assessment;
    final transactions = business == null
        ? const <Transaction>[]
        : ref.watch(transactionsProvider(business.id)).value ??
            const <Transaction>[];

    final currentRevenue = transactions
        .where((t) => t.isInflow)
        .fold<int>(0, (sum, t) => sum + t.amountMinor);
    final predictedRevenue = assessment?.predictedRevenueMinor ?? 0;
    final eligible = assessment?.recommendedAdvanceAmountMinor ?? 0;
    final monthly = _monthlyRevenue(transactions);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Revenue Overview', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CalloutBox(
                      text:
                          'Estimate generated from your Paybill transaction patterns.',
                      icon: Icons.auto_graph,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Current Revenue',
                            value: formatMinor(currentRevenue),
                            icon: Icons.trending_up,
                            iconColor: QcashColors.navy,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Predicted Monthly Revenue',
                            value: formatMinor(predictedRevenue),
                            icon: Icons.auto_graph,
                            iconColor: QcashColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Revenue Trend'),
                    _RevenueChart(data: monthly),
                    const SizedBox(height: 24),
                    const SectionLabel('Historical Revenue'),
                    InfoCard(
                      children: monthly.reversed.take(3).map((e) {
                        return KeyValueRow(
                          label: e.label,
                          value: formatMinor(e.value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    StatCard(
                      label: 'Eligible Early Access',
                      value: formatMinor(eligible),
                      isLarge: true,
                      highlight: true,
                      highlightColor: QcashColors.navy,
                      icon: Icons.bolt,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MonthValue> _monthlyRevenue(List<Transaction> transactions) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final now = DateTime.now();
    final result = <_MonthValue>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      var total = 0;
      for (final t in transactions) {
        if (t.isInflow &&
            t.transactionTime.year == d.year &&
            t.transactionTime.month == d.month) {
          total += t.amountMinor;
        }
      }
      result.add(_MonthValue(months[d.month - 1], total));
    }
    return result;
  }
}

class _MonthValue {
  const _MonthValue(this.label, this.value);

  final String label;
  final int value;
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart({required this.data});

  final List<_MonthValue> data;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: QcashColors.iconBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((e) {
                final factor = maxValue == 0 ? 0.0 : (e.value / maxValue).clamp(0.05, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FractionallySizedBox(
                      heightFactor: factor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: e.value == maxValue && maxValue != 0
                              ? QcashColors.green
                              : QcashColors.green.withValues(alpha: 0.4),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data.map((e) {
              return Expanded(
                child: Text(
                  e.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, color: QcashColors.textGray),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
