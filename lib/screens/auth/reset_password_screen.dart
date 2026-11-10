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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String _code = '';
  final bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_code.length < 6) {
      _showError('Enter the 6-digit code.');
      return;
    }
    if (_password.text != _confirm.text) {
      _showError('Passwords do not match.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(
            phoneNumber: widget.phone,
            otp: _code,
            password: _password.text,
            passwordConfirmation: _confirm.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully. Please log in.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => route.isFirst,
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref.read(authControllerProvider.notifier).resendOtp(
            purpose: 'password_reset',
            phoneNumber: widget.phone,
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
              const ScreenHeader(title: 'Reset Password', showBack: true),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Code sent to ${widget.phone}',
                  style: const TextStyle(fontSize: 14, color: QcashColors.textGray),
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
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: _decoration('New Password'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirm,
                obscureText: _obscure,
                decoration: _decoration('Confirm Password'),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Reset Password',
                onPressed: _busy ? null : _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(color: QcashColors.navy),
      filled: true,
      fillColor: QcashColors.iconBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: QcashColors.green, width: 1.5),
      ),
    );
  }
}
