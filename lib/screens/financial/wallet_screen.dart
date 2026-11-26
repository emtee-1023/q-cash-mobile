import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/wallet.dart';
import '../../core/providers/business_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import 'withdraw_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    if (business == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: QcashColors.green),
        ),
      );
    }
    final walletAsync = ref.watch(walletProvider(business.id));
    final withdrawals =
        ref.watch(withdrawalsProvider(business.id)).value ??
        const <Withdrawal>[];

    final balanceText = walletAsync.when(
      data: (wallet) => formatMinor(wallet.balanceMinor),
      loading: () => '…',
      error: (_, _) => '—',
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: RefreshIndicator(
                color: QcashColors.green,
                onRefresh: () async {
                  ref.invalidate(walletProvider(business.id));
                  ref.invalidate(withdrawalsProvider(business.id));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _balanceHero(context, balanceText),
                      const SizedBox(height: 16),
                      const CalloutBox(
                        text:
                            'Withdrawals are sent instantly to the M-Pesa number '
                            'registered on your account.',
                        icon: Icons.schedule,
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel('Withdrawal History'),
                      if (withdrawals.isEmpty)
                        _emptyState(context)
                      else
                        ...withdrawals.map((w) => _withdrawalTile(context, w)),
                      const SizedBox(height: 12),
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

  Widget _header(BuildContext context) {
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
                  text: 'Business ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.qc.text,
                  ),
                ),
                TextSpan(
                  text: 'Wallet',
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
            'Keep an eye on your balance and cash out to M-Pesa anytime.',
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

  Widget _balanceHero(BuildContext context, String balanceText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [QcashColors.green, Color(0xFF158A6C)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: QcashColors.green.withValues(alpha: 0.3),
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
              const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Available Balance',
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'KES',
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
            balanceText,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const WithdrawScreen())),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Withdraw to M-Pesa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.qc.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.receipt_long_outlined, color: context.qc.muted),
          ),
          const SizedBox(height: 12),
          Text(
            'No withdrawals yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.qc.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your cash-outs to M-Pesa will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.qc.muted),
          ),
        ],
      ),
    );
  }

  Widget _withdrawalTile(BuildContext context, Withdrawal w) {
    final color = _statusColor(w.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.qc.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.north_east, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatMinor(w.amountMinor),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.qc.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'To ${formatKenyanPhone(w.recipientPhoneNumber)}',
                  style: TextStyle(fontSize: 12, color: context.qc.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  w.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatDate(w.requestedAt),
                style: TextStyle(fontSize: 11, color: context.qc.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
      case 'successful':
        return QcashColors.green;
      case 'failed':
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return QcashColors.orange;
    }
  }
}
