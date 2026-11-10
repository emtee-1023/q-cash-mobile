import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import 'access_confirmation_screen.dart';

class AccessRevenueScreen extends StatefulWidget {
  const AccessRevenueScreen({super.key});

  @override
  State<AccessRevenueScreen> createState() => _AccessRevenueScreenState();
}

class _AccessRevenueScreenState extends State<AccessRevenueScreen> {
  static const double _max = 25000;
  double _amount = 5000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Access Revenue', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StatCard(
                      label: 'Maximum Available',
                      value: 'KES 25,000',
                      isLarge: true,
                      highlight: true,
                    ),
                    const SizedBox(height: 24),
                    const SectionLabel('Amount to Access'),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: QcashColors.iconBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: QcashColors.border),
                      ),
                      child: Text(
                        'KES ${_amount.round()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: QcashColors.navy,
                        ),
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: QcashColors.green,
                        inactiveTrackColor: QcashColors.border,
                        thumbColor: QcashColors.green,
                        overlayColor: QcashColors.green.withValues(alpha: 0.15),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: _amount,
                        min: 0,
                        max: _max,
                        onChanged: (v) => setState(() => _amount = v),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('KES 0',
                            style: TextStyle(
                                fontSize: 12, color: QcashColors.textGray)),
                        Text('KES Max',
                            style: TextStyle(
                                fontSize: 12, color: QcashColors.textGray)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CalloutBox(
                      text: 'Zero-Interest — No Access Fee',
                      icon: Icons.bolt,
                    ),
                    const SizedBox(height: 16),
                    const InfoCard(
                      children: [
                        KeyValueRow(label: 'Amount Received', value: 'KES 5,000'),
                        KeyValueRow(label: 'Expected Repayment', value: 'KES 5,000'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AccessConfirmationScreen(amount: _amount),
                        ),
                      ),
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
