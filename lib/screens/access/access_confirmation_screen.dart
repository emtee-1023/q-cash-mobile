import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/finance_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
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
      await controller.acceptOffer();
      try {
        await controller.disburse();
      } catch (_) {
        // The advance exists even if disbursement needs to be retried.
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccessSuccessScreen()),
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not confirm your access. Please try again.');
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
        body: Center(child: CircularProgressIndicator(color: QcashColors.green)),
      );
    }
    final received = offer.offeredAmountMinor;
    final fee = offer.feeAmountMinor;
    final repayable = offer.totalRepayableMinor;
    final dueDate = offer.offeredAt.add(Duration(days: offer.maximumRepaymentDays));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Confirm Access', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InfoCard(
                      children: [
                        KeyValueRow(label: 'Requested Amount', value: formatMinor(received)),
                        KeyValueRow(label: 'Processing Fee', value: formatMinor(fee)),
                        KeyValueRow(label: 'Total Received', value: formatMinor(received)),
                        KeyValueRow(label: 'Repayment Amount', value: formatMinor(repayable)),
                        KeyValueRow(label: 'Repayment Date', value: formatDate(dueDate)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CalloutBox(
                      text:
                          'Repayment is deducted automatically from future '
                          'Paybill transactions.',
                      icon: Icons.schedule,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Confirm Access',
                      color: QcashColors.green,
                      onPressed: _busy ? null : _confirm,
                    ),
                    const SizedBox(height: 12),
                    OutlineButton(
                      label: 'Cancel',
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
}
