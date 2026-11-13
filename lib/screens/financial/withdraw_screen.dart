import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
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
    final amount = _amountMinor;
    if (business == null || amount == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(businessRepositoryProvider).createWithdrawal(
            business.id,
            amount,
          );
      if (!mounted) return;
      ref.invalidate(withdrawalsProvider(business.id));
      ref.invalidate(walletProvider(business.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal requested.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not request withdrawal. Please try again.');
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
    final balance = ref.watch(walletProvider(business!.id)).value;
    final available = balance?.balanceMinor ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Withdraw to M-Pesa', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StatCard(
                        label: 'Available Balance',
                        value: formatMinor(available),
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: QcashColors.green,
                      ),
                      const SizedBox(height: 20),
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
                          if (minor > available) {
                            return 'Amount exceeds available balance';
                          }
                          return null;
                        },
                      ),
                      const CalloutBox(
                        text:
                            'The amount will be sent to the phone number '
                            'registered on your account.',
                        icon: Icons.smartphone,
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Withdraw',
                        color: QcashColors.green,
                        onPressed: (_busy || _amountMinor == null)
                            ? null
                            : _submit,
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
