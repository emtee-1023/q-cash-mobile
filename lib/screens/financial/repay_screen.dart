import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/models/advance.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/phone_field.dart';
import '../../widgets/screen_header.dart';

class RepayScreen extends ConsumerStatefulWidget {
  const RepayScreen({super.key});

  @override
  ConsumerState<RepayScreen> createState() => _RepayScreenState();
}

enum _RepayMethod { wallet, mpesa }

class _RepayScreenState extends ConsumerState<RepayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _phone = TextEditingController();
  _RepayMethod _method = _RepayMethod.wallet;
  bool _busy = false;
  String _idempotencyKey = _newIdempotencyKey();

  static String _newIdempotencyKey() =>
      'wallet-repay-${DateTime.now().microsecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phone = ref.read(userProvider).value?.phoneNumber;
      if (!mounted || _phone.text.isNotEmpty || phone == null) return;
      _phone.text = _localPhone(phone);
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _phone.dispose();
    super.dispose();
  }

  int? get _amountMinor {
    final text = _amount.text.trim().replaceAll(',', '');
    if (text.isEmpty) return null;
    final value = num.tryParse(text);
    if (value == null) return null;
    return (value * 100).round();
  }

  void _useFullOutstanding(int totalOutstanding) {
    final whole = totalOutstanding ~/ 100;
    final cents = totalOutstanding % 100;
    setState(() {
      _amount.text = cents == 0
          ? '$whole'
          : '$whole.${cents.toString().padLeft(2, '0')}';
      _idempotencyKey = _newIdempotencyKey();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final business = ref.read(currentBusinessProvider);
    final amount = _amountMinor;
    if (business == null || amount == null) return;

    setState(() => _busy = true);
    try {
      if (_method == _RepayMethod.wallet) {
        await ref
            .read(financeRepositoryProvider)
            .repayFromWallet(
              business.id,
              amountMinor: amount,
              idempotencyKey: _idempotencyKey,
            );
        ref.invalidate(advancesProvider(business.id));
        ref.invalidate(walletProvider(business.id));
        _showInfo('Repayment successful.');
      } else {
        final phone = toKenyanMsisdn(_phone.text);
        if (phone == null) {
          _showError('Enter a valid phone number.');
          return;
        }
        await ref
            .read(financeRepositoryProvider)
            .repayViaMpesa(
              business.id,
              phoneNumber: phone,
              amountMinor: amount,
            );
        ref.invalidate(advancesProvider(business.id));
        _showInfo(
          'STK push sent. Enter your M-Pesa PIN to complete the payment.',
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not complete repayment. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _localPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('254') && digits.length == 12) {
      final local = '0${digits.substring(3)}';
      return '${local.substring(0, 4)} ${local.substring(4, 7)} '
          '${local.substring(7)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(currentBusinessProvider);
    final advancesAsync = business == null
        ? null
        : ref.watch(advancesProvider(business.id));
    final advances = advancesAsync?.value ?? const <Advance>[];
    final loadingAdvances =
        advancesAsync != null &&
        advancesAsync.isLoading &&
        !advancesAsync.hasValue;
    final totalOutstanding = advances.fold<int>(
      0,
      (sum, advance) => sum + advance.outstandingBalanceMinor,
    );
    final wallet = business == null
        ? null
        : ref.watch(walletProvider(business.id)).value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Make a Repayment', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: loadingAdvances
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: QcashColors.green,
                          ),
                        ),
                      )
                    : totalOutstanding <= 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No outstanding balance to repay.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.qc.muted),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const CalloutBox(
                              text:
                                  'Repayments are deducted automatically from '
                                  'eligible incoming payments. You can also '
                                  'repay early from your wallet or via M-Pesa. '
                                  'Overdue and oldest advances are cleared first.',
                              icon: Icons.autorenew,
                            ),
                            const SizedBox(height: 16),
                            InfoCard(
                              children: [
                                KeyValueRow(
                                  label: 'Outstanding balance',
                                  value: formatMinor(totalOutstanding),
                                ),
                                KeyValueRow(
                                  label: 'Wallet balance',
                                  value: wallet == null
                                      ? '—'
                                      : formatMinor(wallet.balanceMinor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const SectionLabel('Payment method'),
                            _methodOption(
                              method: _RepayMethod.wallet,
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'QCash wallet',
                              subtitle: wallet == null
                                  ? 'Pay instantly from your wallet.'
                                  : 'Available: '
                                        '${formatMinor(wallet.balanceMinor)}',
                            ),
                            const SizedBox(height: 10),
                            _methodOption(
                              method: _RepayMethod.mpesa,
                              icon: Icons.phone_iphone,
                              title: 'M-Pesa',
                              subtitle:
                                  'Receive an STK push and pay with your '
                                  'M-Pesa PIN.',
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              label: 'Amount (KES)',
                              hint: '0',
                              controller: _amount,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixText: 'KES ',
                              onChanged: (_) => setState(() {
                                _idempotencyKey = _newIdempotencyKey();
                              }),
                              validator: (v) {
                                final minor = _amountMinor;
                                if (minor == null || minor <= 0) {
                                  return 'Enter a valid amount';
                                }
                                if (minor > totalOutstanding) {
                                  return 'Amount exceeds outstanding balance';
                                }
                                if (_method == _RepayMethod.wallet &&
                                    wallet != null &&
                                    minor > wallet.balanceMinor) {
                                  return 'Amount exceeds wallet balance';
                                }
                                return null;
                              },
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _busy
                                    ? null
                                    : () =>
                                          _useFullOutstanding(totalOutstanding),
                                child: Text(
                                  'Use full ${formatMinor(totalOutstanding)}',
                                  style: const TextStyle(
                                    color: QcashColors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            if (_method == _RepayMethod.mpesa)
                              PhoneField(
                                controller: _phone,
                                label: 'M-Pesa Phone Number',
                                hint: '0712 345 678',
                              ),
                            const SizedBox(height: 8),
                            PrimaryButton(
                              label: _method == _RepayMethod.wallet
                                  ? 'Pay from wallet'
                                  : 'Send M-Pesa request',
                              color: QcashColors.green,
                              onPressed: _busy || _amountMinor == null
                                  ? null
                                  : _submit,
                            ),
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

  Widget _methodOption({
    required _RepayMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _method == method;
    return InkWell(
      onTap: () => setState(() => _method = method),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? QcashColors.green.withValues(alpha: 0.1)
              : context.qc.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? QcashColors.green : context.qc.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? QcashColors.green : context.qc.muted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.qc.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.qc.muted),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 20, color: context.qc.muted),
          ],
        ),
      ),
    );
  }
}
