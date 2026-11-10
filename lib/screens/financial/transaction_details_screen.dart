import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/models/transaction.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Transaction Details', showBack: true),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: QcashColors.iconBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${t.isInflow ? '+' : '-'}${formatMinorAmount(t.amountMinor)}',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: t.isInflow ? QcashColors.green : QcashColors.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.providerStatus ?? 'Completed',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: QcashColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoCard(
                    children: [
                      KeyValueRow(
                        label: 'Reference',
                        value: t.providerTransactionId,
                      ),
                      KeyValueRow(
                        label: 'Date / Time',
                        value: formatDate(t.transactionTime, withTime: true),
                      ),
                      KeyValueRow(
                        label: 'Amount',
                        value: formatMinor(t.amountMinor),
                      ),
                      KeyValueRow(
                        label: 'Type',
                        value: t.transactionType ?? (t.isInflow ? 'Income' : 'Outflow'),
                      ),
                      KeyValueRow(
                        label: 'Status',
                        value: t.providerStatus ?? 'Completed',
                      ),
                      KeyValueRow(
                        label: 'Related Account',
                        value: t.counterpartyReference ??
                            (t.paymentAccountId != null ? 'Account ${t.paymentAccountId}' : '—'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
