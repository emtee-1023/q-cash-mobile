import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    child: const Column(
                      children: [
                        Text(
                          'KES 5,000',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: QcashColors.navy,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: QcashColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InfoCard(
                    children: [
                      KeyValueRow(label: 'Reference', value: 'QC-00291'),
                      KeyValueRow(label: 'Date / Time', value: '3 Sep, 10:42'),
                      KeyValueRow(label: 'Amount', value: 'KES 5,000'),
                      KeyValueRow(label: 'Type', value: 'Early Access'),
                      KeyValueRow(label: 'Status', value: 'Completed'),
                      KeyValueRow(label: 'Related Account', value: 'Paybill 4521'),
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
