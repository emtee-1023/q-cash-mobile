import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/models/business.dart';
import '../../core/providers/business_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class MpesaConnectionScreen extends ConsumerStatefulWidget {
  const MpesaConnectionScreen({super.key, required this.business});

  final Business business;

  @override
  ConsumerState<MpesaConnectionScreen> createState() =>
      _MpesaConnectionScreenState();
}

class _MpesaConnectionScreenState extends ConsumerState<MpesaConnectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumber = TextEditingController();
  final _accountReference = TextEditingController();
  final _accountName = TextEditingController();
  String? _provider = 'Safaricom';
  String? _channelType = 'Paybill';
  bool _busy = false;

  @override
  void dispose() {
    _accountNumber.dispose();
    _accountReference.dispose();
    _accountName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(businessesProvider.notifier).addPaymentAccount(
            widget.business.id,
            {
              'provider': _provider,
              'channel_type': _channelType,
              'account_number': _accountNumber.text.trim(),
              if (_accountReference.text.trim().isNotEmpty)
                'account_reference': _accountReference.text.trim(),
              if (_accountName.text.trim().isNotEmpty)
                'account_name': _accountName.text.trim(),
            },
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not connect your account. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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
                child: Form(
                  key: _formKey,
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
                      AppDropdownField(
                        label: 'Provider',
                        hint: 'Select provider',
                        value: _provider,
                        items: const ['Safaricom'],
                        onChanged: (v) => setState(() => _provider = v),
                      ),
                      AppDropdownField(
                        label: 'Channel Type',
                        hint: 'Select channel',
                        value: _channelType,
                        items: const ['Paybill', 'Till'],
                        onChanged: (v) => setState(() => _channelType = v),
                      ),
                      AppTextField(
                        label: 'Paybill Number',
                        hint: 'e.g. 522533',
                        controller: _accountNumber,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Paybill number is required' : null,
                      ),
                      AppTextField(
                        label: 'Business / Account Number',
                        hint: 'Your Paybill account number',
                        controller: _accountReference,
                      ),
                      AppTextField(
                        label: 'Account Name (optional)',
                        hint: 'Wanjiru General Store',
                        controller: _accountName,
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Continue',
                        color: QcashColors.green,
                        onPressed: _busy ? null : _submit,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
