import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/models/advance.dart';
import '../../core/models/business.dart';
import '../../core/models/transaction.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/cards.dart';
import '../access/access_revenue_screen.dart';
import '../account/notifications_screen.dart';
import '../account/profile_screen.dart';
import '../financial/repayment_screen.dart';
import '../financial/request_payment_screen.dart';
import '../financial/transactions_screen.dart';
import '../financial/wallet_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TransactionsScreen()),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AccessRevenueScreen()),
        );
        break;
      case 3:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RepaymentScreen()),
        );
        break;
      case 4:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    if (business == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: QcashColors.green)),
      );
    }

    final advances =
        ref.watch(advancesProvider(business.id)).value ?? const <Advance>[];
    final transactions = ref.watch(transactionsProvider(business.id)).value ??
        const <Transaction>[];
    final wallet = ref.watch(walletProvider(business.id)).value;
    final available =
        ref.watch(accessControllerProvider).assessment?.recommendedAdvanceAmountMinor ?? 0;

    final balance = wallet?.balanceMinor ?? business.walletBalanceMinor;
    final todayEarnings = _todayEarnings(transactions);
    final outstanding = _outstanding(advances);
    final latest = _latestAdvance(advances);

    final user = ref.watch(userProvider).value;
    final firstName = (user?.name.trim().split(RegExp(r'\s+')).first ?? '');
    final greeting = firstName.isEmpty ? 'there' : firstName;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context, ref, business, greeting),
            Expanded(
              child: RefreshIndicator(
                color: QcashColors.green,
                onRefresh: () async {
                  ref.invalidate(advancesProvider(business.id));
                  ref.invalidate(transactionsProvider(business.id));
                  ref.invalidate(walletProvider(business.id));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _walletHero(context, business, balance),
                      const SizedBox(height: 14),
                      _advanceCard(context, available),
                      const SizedBox(height: 20),
                      const SectionLabel('Overview'),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: "Today's earnings",
                              value: formatMinor(todayEarnings),
                              icon: Icons.trending_up,
                              iconColor: QcashColors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Outstanding balance',
                              value: formatMinor(outstanding),
                              icon: Icons.receipt_long_outlined,
                              iconColor: QcashColors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _latestAdvanceTile(context, latest),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SectionLabel('Recent Transactions'),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const TransactionsScreen()),
                            ),
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: QcashColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (transactions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No transactions yet. Once your Paybill is connected, '
                            'transactions will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: QcashColors.textGray),
                          ),
                        )
                      else
                        ...transactions.take(3).map(_transactionTile),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            BottomNavBar(currentIndex: 0, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    WidgetRef ref,
    Business business,
    String greeting,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $greeting',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                _businessSwitcher(context, business),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: QcashColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_none,
                  color: QcashColors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessSwitcher(BuildContext context, Business business) {
    return InkWell(
      onTap: () => _showBusinessSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
        decoration: BoxDecoration(
          color: QcashColors.iconBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: QcashColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: QcashColors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront, size: 14,
                  color: QcashColors.green),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                business.businessName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: QcashColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down,
                size: 18, color: QcashColors.textGray),
          ],
        ),
      ),
    );
  }

  void _showBusinessSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Consumer(
          builder: (context, sheetRef, _) {
            final businesses =
                sheetRef.watch(businessesProvider).value ?? const <Business>[];
            final currentId = sheetRef.watch(currentBusinessProvider)?.id;
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Switch business',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: QcashColors.navy,
                          ),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: businesses
                                .map((b) => _businessOption(
                                    sheetContext, sheetRef, b, currentId))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _businessOption(
    BuildContext context,
    WidgetRef ref,
    Business business,
    int? currentId,
  ) {
    final selected = business.id == currentId;
    final initial = business.businessName.trim().isEmpty
        ? 'Q'
        : business.businessName.trim()[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          ref.read(selectedBusinessIdProvider.notifier).select(business.id);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? QcashColors.green.withValues(alpha: 0.08)
                : QcashColors.iconBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? QcashColors.green.withValues(alpha: 0.5)
                  : QcashColors.border,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: QcashColors.green.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: QcashColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.businessName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: QcashColors.navy,
                      ),
                    ),
                    if (business.typeName != null &&
                        business.typeName!.isNotEmpty)
                      Text(
                        business.typeName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: QcashColors.textGray,
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    color: QcashColors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletHero(BuildContext context, Business business, int balance) {
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
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Business Wallet',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            'Available balance',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatMinor(balance),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _walletAction(
                  Icons.arrow_upward,
                  'Withdraw',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WalletScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _walletAction(
                  Icons.request_quote_outlined,
                  'Prompt Customer',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RequestPaymentScreen(business: business),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _advanceCard(BuildContext context, int available) {
    final hasAmount = available > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: QcashColors.navy,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: QcashColors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Available cash advance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  hasAmount ? formatMinor(available) : 'Check your limit',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: QcashColors.green,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccessRevenueScreen()),
            ),
            child: Text(hasAmount ? 'Get advance' : 'Check now'),
          ),
        ],
      ),
    );
  }

  Widget _latestAdvanceTile(BuildContext context, Advance? latest) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QcashColors.iconBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: QcashColors.purpleAlt.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.south_east,
                color: QcashColors.purpleAlt, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest cash advance',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: QcashColors.textGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  latest == null
                      ? 'No advances yet'
                      : formatMinor(latest.principalAmountMinor),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: QcashColors.navy,
                  ),
                ),
              ],
            ),
          ),
          if (latest != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  latest.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: QcashColors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDate(latest.createdAt ?? latest.disbursedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: QcashColors.textGray,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  int _todayEarnings(List<Transaction> transactions) {
    final now = DateTime.now();
    var total = 0;
    for (final t in transactions) {
      if (!t.isInflow) continue;
      final d = t.transactionTime.toLocal();
      if (d.year == now.year && d.month == now.month && d.day == now.day) {
        total += t.amountMinor;
      }
    }
    return total;
  }

  int _outstanding(List<Advance> advances) {
    var total = 0;
    for (final a in advances) {
      total += a.outstandingBalanceMinor;
    }
    return total;
  }

  Advance? _latestAdvance(List<Advance> advances) {
    if (advances.isEmpty) return null;
    final sorted = [...advances]..sort((a, b) {
        final ad = a.createdAt ?? a.disbursedAt ?? DateTime(0);
        final bd = b.createdAt ?? b.disbursedAt ?? DateTime(0);
        return bd.compareTo(ad);
      });
    return sorted.first;
  }

  Widget _transactionTile(Transaction t) {
    return TransactionTile(
      title: t.counterpartyName ??
          (t.isInflow ? 'Paybill Deposit' : 'M-Pesa Outflow'),
      subtitle: formatDate(t.transactionTime),
      amount: formatMinorAmount(t.amountMinor),
      positive: t.isInflow,
    );
  }
}
