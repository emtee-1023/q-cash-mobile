import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../home/dashboard_screen.dart';

class AccessSuccessScreen extends ConsumerWidget {
  const AccessSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(accessControllerProvider);
    final advance = access.advance;
    if (advance == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: QcashColors.green)),
      );
    }
    final recommended = access.assessment?.recommendedAdvanceAmountMinor ?? 0;
    final diff = recommended - advance.principalAmountMinor;
    final remaining = diff < 0 ? 0 : diff;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: QcashColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Advance Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: QcashColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your cash advance is on its way to your M-Pesa.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: QcashColors.textGray),
              ),
              const SizedBox(height: 24),
              InfoCard(
                children: [
                  KeyValueRow(
                    label: 'Advance amount',
                    value: formatMinor(advance.principalAmountMinor),
                  ),
                  KeyValueRow(label: 'Reference', value: advance.publicId),
                  KeyValueRow(
                    label: 'Date',
                    value: formatDate(advance.disbursedAt ?? advance.createdAt ?? DateTime.now()),
                  ),
                  KeyValueRow(
                    label: 'Remaining available balance',
                    value: formatMinor(remaining),
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Back to Dashboard',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (route) => false,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
