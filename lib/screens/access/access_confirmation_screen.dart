import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/access_fee.dart';
import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../core/providers/notification_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import 'access_success_screen.dart';

class AccessConfirmationScreen extends ConsumerStatefulWidget {
  const AccessConfirmationScreen({super.key});

  @override
  ConsumerState<AccessConfirmationScreen> createState() =>
      _AccessConfirmationScreenState();
}

class _AccessConfirmationScreenState
    extends ConsumerState<AccessConfirmationScreen> {
  bool _busy = false;

  Future<void> _confirm() async {
    setState(() => _busy = true);
    try {
      final controller = ref.read(accessControllerProvider.notifier);
      var advance =
          ref.read(accessControllerProvider).advance ??
          await controller.acceptOffer();
      if (advance.status == 'pending') {
        advance = await controller.approve();
      }
      if (advance.status == 'approved') {
        advance = await controller.disburse();
      }
      if (!mounted) return;

      ref.invalidate(walletProvider(advance.businessId));
      ref.invalidate(advancesProvider(advance.businessId));
      ref.invalidate(analyticsProvider(advance.businessId));
      ref.invalidate(notificationInboxProvider);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccessSuccessScreen()),
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not complete your advance. Please try again.');
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
    final offer = ref.watch(accessControllerProvider).offer;
    if (offer == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: QcashColors.green),
        ),
      );
    }
    final received = offer.offeredAmountMinor;
    final fee = offer.feeAmountMinor;
    final repayable = offer.totalRepayableMinor;
    final feeBps = repayable <= 0 ? 0 : (fee * 10000 / repayable).round();
    final dueDate = offer.offeredAt.add(
      Duration(days: offer.maximumRepaymentDays),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _hero(received),
                    const SizedBox(height: 16),
                    const CalloutBox(
                      text:
                          'The access fee is deducted upfront. Your advance is '
                          'credited to your QCash wallet and you repay the full '
                          'advance amount.',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 16),
                    InfoCard(
                      children: [
                        KeyValueRow(
                          label: 'You receive',
                          value: formatMinor(received),
                        ),
                        KeyValueRow(
                          label: 'Access fee (${formatBps(feeBps)})',
                          value: formatMinor(fee),
                        ),
                        KeyValueRow(
                          label: 'You repay',
                          value: formatMinor(repayable),
                        ),
                        KeyValueRow(
                          label: 'Repayment window',
                          value:
                              'Up to '
                              '${cappedRepaymentDays(offer.maximumRepaymentDays)} '
                              'days',
                        ),
                        KeyValueRow(
                          label: 'First repayment due',
                          value: formatDate(dueDate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Accept Advance',
                      color: QcashColors.green,
                      onPressed: _busy ? null : _confirm,
                    ),
                    const SizedBox(height: 12),
                    OutlineButton(
                      label: 'Not now',
                      onPressed: () => Navigator.of(context).pop(),
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
                border: Border.all(color: context.qc.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chevron_left, size: 24),
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Confirm ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.qc.text,
                  ),
                ),
                TextSpan(
                  text: 'Advance',
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
          Text(
            'Review the terms of your cash advance before you accept.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: context.qc.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(int received) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [QcashColors.navy, QcashColors.navyDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: QcashColors.navy.withValues(alpha: 0.28),
            offset: const Offset(0, 8),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: QcashColors.green, size: 18),
              const SizedBox(width: 8),
              const Text(
                'You receive',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: QcashColors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Zero interest',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatMinor(received),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Disbursed to your M-Pesa number',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
