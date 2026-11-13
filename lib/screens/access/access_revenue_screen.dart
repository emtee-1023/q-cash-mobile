import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import 'access_confirmation_screen.dart';

class AccessRevenueScreen extends ConsumerStatefulWidget {
  const AccessRevenueScreen({super.key});

  @override
  ConsumerState<AccessRevenueScreen> createState() => _AccessRevenueScreenState();
}

class _AccessRevenueScreenState extends ConsumerState<AccessRevenueScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final business = ref.read(currentBusinessProvider);
    final controller = ref.read(accessControllerProvider.notifier);
    if (business == null) return;
    if (ref.read(accessControllerProvider).assessment != null) return;
    try {
      await controller.requestAssessment(business.id);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.readable);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not check your eligibility.');
    }
  }

  Future<void> _continue() async {
    final business = ref.read(currentBusinessProvider);
    if (business == null) return;
    setState(() => _error = null);
    try {
      await ref.read(accessControllerProvider.notifier).createOffer(business.id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AccessConfirmationScreen()),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.readable);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not prepare your advance.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(accessControllerProvider);
    final assessment = access.assessment;
    final available = assessment?.recommendedAdvanceAmountMinor ?? 0;

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
                    if (assessment == null && _error == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: QcashColors.green),
                            SizedBox(height: 16),
                            Text(
                              'Checking your eligibility…',
                              style: TextStyle(color: QcashColors.textGray),
                            ),
                          ],
                        ),
                      )
                    else if (_error != null && assessment == null) ...[
                      const SizedBox(height: 32),
                      CalloutBox(text: _error!, icon: Icons.error_outline),
                      const SizedBox(height: 16),
                      PrimaryButton(label: 'Try Again', onPressed: _load),
                    ] else ...[
                      _advanceHero(available),
                      const SizedBox(height: 16),
                      const CalloutBox(
                        text:
                            'Zero interest. Repaid automatically from your future '
                            'sales as they come in.',
                        icon: Icons.schedule,
                      ),
                      const SizedBox(height: 16),
                      InfoCard(
                        children: [
                          KeyValueRow(
                            label: 'You receive',
                            value: formatMinor(available),
                          ),
                          KeyValueRow(
                            label: 'You repay',
                            value: formatMinor(available),
                          ),
                          const KeyValueRow(label: 'Interest', value: '0%'),
                          if (assessment?.maximumRepaymentDays != null)
                            KeyValueRow(
                              label: 'Repayment window',
                              value: '${assessment!.maximumRepaymentDays} days',
                            ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(
                              color: Color(0xFFE53935), fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Continue',
                        color: QcashColors.green,
                        onPressed: available > 0 ? _continue : null,
                      ),
                    ],
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
                  text: 'Cash ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: QcashColors.navy,
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
          const Text(
            'Get an instant advance on your business earnings, with no interest.',
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

  Widget _advanceHero(int available) {
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
                'Available cash advance',
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
            formatMinor(available),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Based on your recent business earnings',
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
