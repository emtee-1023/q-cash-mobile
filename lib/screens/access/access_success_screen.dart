import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../home/dashboard_screen.dart';

class AccessSuccessScreen extends StatelessWidget {
  const AccessSuccessScreen({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final formatted = amount.round();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: QcashColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Access Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: QcashColors.navy,
                ),
              ),
              const SizedBox(height: 24),
              InfoCard(
                children: [
                  KeyValueRow(label: 'Amount Accessed', value: 'KES $formatted'),
                  const KeyValueRow(label: 'Transaction Ref', value: 'QC-00291'),
                  const KeyValueRow(label: 'Date', value: '3 Sep 2026'),
                  const KeyValueRow(
                      label: 'Updated Available Balance', value: 'KES 20,000'),
                ],
              ),
              const Spacer(),
              OutlineButton(
                label: 'View Details',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Back to Dashboard',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
