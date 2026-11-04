import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import '../home/dashboard_screen.dart';

class MpesaConnectionScreen extends StatefulWidget {
  const MpesaConnectionScreen({super.key});

  @override
  State<MpesaConnectionScreen> createState() => _MpesaConnectionScreenState();
}

class _MpesaConnectionScreenState extends State<MpesaConnectionScreen> {
  bool _connected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Connect M-Pesa', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CalloutBox(
                      text:
                          'Q-Cash reads your Paybill transaction history to '
                          'assess business revenue and eligibility.',
                      icon: Icons.receipt_long,
                    ),
                    const SizedBox(height: 16),
                    const AppTextField(
                      label: 'Paybill Number',
                      hint: 'e.g. 522533',
                      keyboardType: TextInputType.number,
                    ),
                    const AppTextField(
                      label: 'Business / Account Number',
                      hint: 'Your Paybill account number',
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: QcashColors.iconBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Connection Status',
                            style: TextStyle(
                                fontSize: 13, color: QcashColors.textGray),
                          ),
                          Row(
                            children: [
                              Icon(
                                _connected
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: _connected
                                    ? QcashColors.green
                                    : QcashColors.textGray,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _connected ? 'Connected' : 'Not Connected',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _connected
                                      ? QcashColors.green
                                      : QcashColors.textGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlineButton(
                      label: _connected ? 'Reconnect Account' : 'Connect Account',
                      onPressed: () => setState(() => _connected = true),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: 'Continue',
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
          ],
        ),
      ),
    );
  }
}
