import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/business_providers.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
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
      if (mounted) setState(() => _error = 'Could not run your assessment.');
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
      if (mounted) setState(() => _error = 'Could not prepare your offer.');
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
            const ScreenHeader(title: 'Access Revenue', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (assessment == null && _error == null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(color: QcashColors.green),
                        ),
                      )
                    else if (_error != null && assessment == null) ...[
                      const SizedBox(height: 40),
                      CalloutBox(
                        text: _error!,
                        icon: Icons.error_outline,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Try Again',
                        onPressed: () => _load(),
                      ),
                    ] else ...[
                      StatCard(
                        label: 'Maximum Available',
                        value: formatMinor(available),
                        isLarge: true,
                        highlight: true,
                        highlightColor: QcashColors.navy,
                        icon: Icons.bolt,
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel('Amount to Access'),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: QcashColors.iconBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: QcashColors.border),
                        ),
                        child: Column(
                          children: [
                            Text(
                              formatMinor(available),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: QcashColors.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Based on your revenue assessment',
                              style: TextStyle(
                                fontSize: 12,
                                color: QcashColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const CalloutBox(
                        text: 'Zero-Interest — No Access Fee',
                        icon: Icons.bolt,
                      ),
                      const SizedBox(height: 16),
                      InfoCard(
                        children: [
                          KeyValueRow(
                            label: 'Amount Received',
                            value: formatMinor(available),
                          ),
                          KeyValueRow(
                            label: 'Expected Repayment',
                            value: formatMinor(available),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: Color(0xFFE53935), fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Continue',
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
}
