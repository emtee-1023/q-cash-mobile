import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/screen_header.dart';

class TwoFactorScreen extends ConsumerStatefulWidget {
  const TwoFactorScreen({super.key});

  @override
  ConsumerState<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends ConsumerState<TwoFactorScreen> {
  String _code = '';
  bool _busy = false;

  Future<void> _verify() async {
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyTwoFactor(otp: _code);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final challenge = ref.read(authControllerProvider).challengeToken;
    try {
      await ref.read(authControllerProvider.notifier).resendOtp(
            purpose: 'two_factor',
            challengeToken: challenge,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent.')),
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(title: 'Two-Factor Verification', showBack: true),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Enter the code sent to your phone.',
                  style: TextStyle(fontSize: 14, color: QcashColors.textGray),
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel('Enter Code'),
              OtpInput(onChanged: (code) => _code = code),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _resend,
                  child: const Text(
                    'Resend Code',
                    style: TextStyle(
                      color: QcashColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Verify',
                onPressed: _busy ? null : _verify,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
