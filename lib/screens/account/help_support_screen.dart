import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Help & Support', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search FAQs',
                        prefixIcon: const Icon(Icons.search, color: QcashColors.textGray),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Frequently Asked Questions'),
                    const _FaqRow(title: 'How Q-Cash Works'),
                    const _FaqRow(title: 'How Early Revenue Access Works'),
                    const _FaqRow(title: 'Repayment Information'),
                    const _FaqRow(title: 'M-Pesa Connection Help'),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Contact Support',
                      color: QcashColors.green,
                      onPressed: () {},
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

class _FaqRow extends StatelessWidget {
  const _FaqRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: QcashColors.navy,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: QcashColors.textGray),
        ],
      ),
    );
  }
}
