import 'package:flutter/material.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/screen_header.dart';
import 'mpesa_connection_screen.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState extends State<BusinessRegistrationScreen> {
  String? _businessType;
  String? _businessCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Business Details', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppTextField(
                      label: 'Business Name',
                      hint: 'Wanjiru General Store',
                    ),
                    AppDropdownField(
                      label: 'Business Type',
                      hint: 'Select type',
                      value: _businessType,
                      items: const [
                        'Sole Proprietorship',
                        'Partnership',
                        'Limited Company',
                        'Informal Business',
                      ],
                      onChanged: (v) => setState(() => _businessType = v),
                    ),
                    const AppTextField(
                      label: 'Business Location',
                      hint: 'Nairobi',
                    ),
                    const AppTextField(
                      label: 'Registration Number (optional)',
                      hint: 'BRS/XXXX/2024',
                    ),
                    AppDropdownField(
                      label: 'Business Category',
                      hint: 'Select category',
                      value: _businessCategory,
                      items: const [
                        'Retail',
                        'Wholesale',
                        'Food & Beverage',
                        'Services',
                        'Transport',
                        'Other',
                      ],
                      onChanged: (v) => setState(() => _businessCategory = v),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MpesaConnectionScreen(),
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
