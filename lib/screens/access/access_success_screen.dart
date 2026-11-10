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
                'Access Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: QcashColors.navy,
                ),
              ),
              const SizedBox(height: 24),
              InfoCard(
                children: [
                  KeyValueRow(
                    label: 'Amount Accessed',
                    value: formatMinor(advance.principalAmountMinor),
                  ),
                  KeyValueRow(label: 'Transaction Ref', value: advance.publicId),
                  KeyValueRow(
                    label: 'Date',
                    value: formatDate(advance.disbursedAt ?? advance.createdAt ?? DateTime.now()),
                  ),
                  KeyValueRow(
                    label: 'Updated Available Balance',
                    value: formatMinor(remaining),
                  ),
                ],
              ),
              const Spacer(),
              OutlineButton(
                label: 'View Details',
                onPressed: () {},
              ),
              const SizedBox(height: 12),
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
