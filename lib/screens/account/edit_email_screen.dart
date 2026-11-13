import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/screen_header.dart';

class EditEmailScreen extends ConsumerStatefulWidget {
  const EditEmailScreen({super.key});

  @override
  ConsumerState<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends ConsumerState<EditEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String _code = '';
  bool _showOtp = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider).value;
      if (user?.email != null && _email.text.isEmpty) {
        _email.text = user!.email!;
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            email: _email.text.trim(),
          );
      if (!mounted) return;
      setState(() => _showOtp = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A verification code has been sent.')),
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerificationCode();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent.')),
      );
    } on ApiException catch (e) {
      _showError(e.readable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.length < 6) {
      _showError('Enter the 6-digit code.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyEmail(otp: _code);
      if (!mounted) return;
      ref.invalidate(userProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified successfully.')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      _showError(e.readable);
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
    final user = ref.watch(userProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Email & Verification', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_showOtp) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              label: 'Email Address',
                              hint: 'you@example.com',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                    .hasMatch(v.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            PrimaryButton(
                              label: 'Update Email',
                              color: QcashColors.green,
                              onPressed: _busy ? null : _updateEmail,
                            ),
                            if (user?.email != null && !(user?.isEmailVerified ?? true))
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: OutlineButton(
                                  label: 'Resend Verification Code',
                                  onPressed: _busy ? null : _resendCode,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const CalloutBox(
                        text: 'Enter the 6-digit code sent to your email.',
                        icon: Icons.mark_email_read_outlined,
                      ),
                      const SizedBox(height: 24),
                      const SectionLabel('Enter Code'),
                      OtpInput(onChanged: (code) => _code = code),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _busy ? null : _resendCode,
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
                      PrimaryButton(
                        label: 'Verify',
                        color: QcashColors.green,
                        onPressed: _busy ? null : _verify,
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
