import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class RevenueOverviewScreen extends StatelessWidget {
  const RevenueOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Current Revenue',
                            value: 'KES 38,000',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Predicted Monthly Revenue',
                            value: 'KES 45,000',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Revenue Trend'),
                    const _RevenueChart(),
                    const SizedBox(height: 24),
                    const SectionLabel('Historical Revenue'),
                    const InfoCard(
                      children: [
                        KeyValueRow(label: 'June', value: 'KES 28,000'),
                        KeyValueRow(label: 'July', value: 'KES 32,000'),
                        KeyValueRow(label: 'August', value: 'KES 38,000'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const StatCard(
                      label: 'Eligible Early Access',
                      value: 'KES 25,000',
                      isLarge: true,
                      highlight: true,
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
}

class _RevenueChart extends StatelessWidget {
  const _RevenueChart();

  @override
  Widget build(BuildContext context) {
    const data = [0.45, 0.65, 0.4, 0.8, 0.6, 0.95];
    const labels = ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'];
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
              children: List.generate(data.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FractionallySizedBox(
                      heightFactor: data[i],
                      child: Container(
                        decoration: BoxDecoration(
                          color: i == data.length - 1
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
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(labels.length, (i) {
              return Expanded(
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10, color: QcashColors.textGray),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
