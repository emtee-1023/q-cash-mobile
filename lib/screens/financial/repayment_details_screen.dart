import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/models/advance.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class RepaymentDetailsScreen extends StatelessWidget {
  const RepaymentDetailsScreen({super.key, required this.advance});

  final Advance advance;

  @override
  Widget build(BuildContext context) {
    final a = advance;
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
                    InfoCard(
                      children: [
                        KeyValueRow(label: 'Advance', value: a.publicId),
                        KeyValueRow(
                          label: 'Principal',
                          value: formatMinor(a.principalAmountMinor),
                        ),
                        KeyValueRow(
                          label: 'Access Fee',
                          value: formatMinor(a.feeAmountMinor),
                        ),
                        KeyValueRow(
                          label: 'Total Repayable',
                          value: formatMinor(a.totalRepayableMinor),
                        ),
                        KeyValueRow(
                          label: 'Amount Repaid',
                          value: formatMinor(a.amountRepaidMinor),
                        ),
                        KeyValueRow(
                          label: 'Principal Repaid',
                          value: formatMinor(a.principalRepaidMinor),
                        ),
                        KeyValueRow(
                          label: 'Fee Repaid',
                          value: formatMinor(a.feeRepaidMinor),
                        ),
                        KeyValueRow(
                          label: 'Remaining',
                          value: formatMinor(a.outstandingBalanceMinor),
                        ),
                        KeyValueRow(label: 'Status', value: a.status),
                        KeyValueRow(
                          label: 'Due Date',
                          value: formatDate(a.dueAt),
                        ),
                      ],
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
