import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/models/business.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/mpesa_banner.dart';
import '../../widgets/phone_field.dart';

class RequestPaymentScreen extends ConsumerStatefulWidget {
  const RequestPaymentScreen({super.key, required this.business});

  final Business business;

  @override
  ConsumerState<RequestPaymentScreen> createState() =>
      _RequestPaymentScreenState();
}

class _RequestPaymentScreenState extends ConsumerState<RequestPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  int? get _amountMinor {
    final text = _amount.text.trim().replaceAll(',', '');
    if (text.isEmpty) return null;
    final value = num.tryParse(text);
    if (value == null) return null;
    return (value * 100).round();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = toKenyanMsisdn(_phone.text);
    final amount = _amountMinor;
    if (phone == null || amount == null) return;
    setState(() => _busy = true);
    try {
      final message = await ref.read(financeRepositoryProvider).initiateStkPush(
            widget.business.id,
            phoneNumber: phone,
            amountMinor: amount,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? 'Payment request sent.' : message)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not send the request. Please try again.');
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
    final detail = ref
            .watch(businessDetailProvider(widget.business.id))
            .value ??
        widget.business;
    final paybill = detail.paybillNumber ?? '—';
    final accountNumber = detail.collectionAccountNumber ?? '—';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const CalloutBox(
                        text:
                            'Send a payment prompt to your customer. They will '
                            'receive an M-Pesa request on their phone.',
                        icon: Icons.sms_outlined,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Customer Phone Number',
                        hint: '0712 345 678',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [KenyanPhoneInputFormatter()],
                        validator: (v) => normalizeKenyanPhone(v ?? '') == null
                            ? 'Enter a valid phone number'
                            : null,
                      ),
                      AppTextField(
                        label: 'Amount (KES)',
                        hint: '0',
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixText: 'KES ',
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final minor = _amountMinor;
                          if (minor == null || minor <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: 'Send Prompt',
                        color: QcashColors.green,
                        onPressed: (_busy || _amountMinor == null)
                            ? null
                            : _submit,
                      ),
                      const SizedBox(height: 28),
                      const SectionLabel('Or share your M-Pesa details'),
                      const SizedBox(height: 4),
                      MpesaBanner(
                        paybill: paybill,
                        accountNumber: accountNumber,
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: QcashColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: const [
                TextSpan(
                  text: 'Prompt ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.navy,
                  ),
                ),
                TextSpan(
                  text: 'Customer',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Send an M-Pesa payment request straight to your customer's phone.",
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: QcashColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
