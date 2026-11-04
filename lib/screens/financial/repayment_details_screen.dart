import 'package:flutter/material.dart';

import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class RepaymentDetailsScreen extends StatelessWidget {
  const RepaymentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Repayment Details', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const InfoCard(
                      children: [
                        KeyValueRow(label: 'Original Amount', value: 'KES 5,000'),
                        KeyValueRow(label: 'Amount Repaid', value: 'KES 1,000'),
                        KeyValueRow(label: 'Remaining', value: 'KES 4,000'),
                        KeyValueRow(label: 'Status', value: 'In Progress'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Repayment Transactions'),
                    const TransactionTile(
                      title: 'Automatic deduction',
                      subtitle: '1 Sep 2026',
                      amount: 'KES 1,000',
                      positive: false,
                    ),
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
