import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/cards.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/screen_header.dart';
import 'login_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _code = '';
  bool _busy = false;

  Future<void> _verify() async {
    final phone = ref.read(authControllerProvider).pendingPhone;
    if (phone == null) {
      _showError('Phone number is missing. Please go back and retry.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyPhone(
            phoneNumber: phone,
            otp: _code,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number verified. Please log in.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final phone = ref.read(authControllerProvider).pendingPhone;
    try {
      await ref.read(authControllerProvider.notifier).resendOtp(
            purpose: 'registration',
            phoneNumber: phone,
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
    final phone = ref.watch(authControllerProvider).pendingPhone ?? '+254 7XX XXX XXX';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ScreenHeader(title: 'OTP Verification', showBack: true),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Code sent to $phone',
                  style: const TextStyle(fontSize: 14, color: QcashColors.textGray),
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel('Enter OTP'),
              OtpInput(onChanged: (code) => _code = code),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _resend,
                  child: const Text(
                    'Resend OTP',
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
