import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import 'access_success_screen.dart';

class AccessConfirmationScreen extends StatelessWidget {
  const AccessConfirmationScreen({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final formatted = amount.round();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Confirm Access', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InfoCard(
                      children: [
                        KeyValueRow(label: 'Requested Amount', value: 'KES $formatted'),
                        const KeyValueRow(label: 'Processing Fee', value: 'KES 0'),
                        KeyValueRow(label: 'Total Received', value: 'KES $formatted'),
                        KeyValueRow(label: 'Repayment Amount', value: 'KES $formatted'),
                        const KeyValueRow(
                            label: 'Repayment Date', value: '30 Sep 2026'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CalloutBox(
                      text:
                          'Repayment is deducted automatically from future '
                          'Paybill transactions.',
                      icon: Icons.schedule,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Confirm Access',
                      color: QcashColors.green,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => AccessSuccessScreen(amount: amount),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlineButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
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
