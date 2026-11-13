import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/models/advance.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class RepayScreen extends ConsumerStatefulWidget {
  const RepayScreen({super.key});

  @override
  ConsumerState<RepayScreen> createState() => _RepayScreenState();
}

class _RepayScreenState extends ConsumerState<RepayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  Advance? _advance;
  bool _busy = false;

  @override
  void dispose() {
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
    final business = ref.read(currentBusinessProvider);
    final advance = _advance;
    final amount = _amountMinor;
    if (business == null || advance == null || amount == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(financeRepositoryProvider).recordRepayment(
            business.id,
            collectionMethod: 'manual_payment',
            amountMinor: amount,
            currency: 'KES',
            idempotencyKey:
                'manual-${DateTime.now().microsecondsSinceEpoch}',
            allocations: [
              {'advance_id': advance.id, 'amount_minor': amount},
            ],
          );
      if (!mounted) return;
      ref.invalidate(advancesProvider(business.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repayment recorded.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not record repayment. Please try again.');
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
    final business = ref.watch(currentBusinessProvider);
    final advances = business == null
        ? const <Advance>[]
        : ref.watch(advancesProvider(business.id)).value ?? const <Advance>[];
    final outstanding = advances
        .where((a) => a.outstandingBalanceMinor > 0)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Make a Repayment', showBack: true),
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
                            'Record a payment you have already made towards an '
                            'active advance.',
                        icon: Icons.payments_outlined,
                      ),
                      const SizedBox(height: 16),
                      if (outstanding.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No active advances to repay.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: QcashColors.textGray),
                          ),
                        )
                      else ...[
                        const SectionLabel('Select Advance'),
                        ...outstanding.map((a) => _advanceOption(a)),
                        const SizedBox(height: 16),
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
                            if (_advance != null &&
                                minor > _advance!.outstandingBalanceMinor) {
                              return 'Amount exceeds outstanding balance';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: 'Record Repayment',
                          color: QcashColors.green,
                          onPressed: (_busy || _advance == null || _amountMinor == null)
                              ? null
                              : _submit,
                        ),
                      ],
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

  Widget _advanceOption(Advance a) {
    final selected = _advance?.id == a.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _advance = a),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? QcashColors.green.withValues(alpha: 0.1)
                : QcashColors.iconBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? QcashColors.green : QcashColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? QcashColors.green : QcashColors.textGray,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advance ${a.publicId}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: QcashColors.navy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Outstanding: ${formatMinor(a.outstandingBalanceMinor)}',
                      style: const TextStyle(
                          fontSize: 12, color: QcashColors.textGray),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
