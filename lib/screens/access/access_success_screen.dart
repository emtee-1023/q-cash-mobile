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
        body: Center(
          child: CircularProgressIndicator(color: QcashColors.green),
        ),
      );
    }
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
              Text(
                'Advance Successful',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.qc.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your cash advance has been credited to your QCash wallet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.qc.muted),
              ),
              const SizedBox(height: 24),
              InfoCard(
                children: [
                  KeyValueRow(
                    label: 'Credited to wallet',
                    value: formatMinor(advance.principalAmountMinor),
                  ),
                  KeyValueRow(
                    label: 'Access fee',
                    value: formatMinor(advance.feeAmountMinor),
                  ),
                  KeyValueRow(
                    label: 'Total to repay',
                    value: formatMinor(advance.totalRepayableMinor),
                  ),
                  KeyValueRow(label: 'Reference', value: advance.publicId),
                  KeyValueRow(
                    label: 'Date',
                    value: formatDate(
                      advance.disbursedAt ??
                          advance.createdAt ??
                          DateTime.now(),
                    ),
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
