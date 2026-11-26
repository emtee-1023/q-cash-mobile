import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import 'login_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _length = 6;
  String _code = '';
  bool _busy = false;

  static const _resendSeconds = 30;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _append(String digit) {
    if (_code.length >= _length || _busy) return;
    setState(() => _code += digit);
  }

  void _backspace() {
    if (_code.isEmpty || _busy) return;
    setState(() => _code = _code.substring(0, _code.length - 1));
  }

  Future<void> _verify() async {
    final phone = ref.read(authControllerProvider).pendingPhone;
    if (phone == null) {
      _showError('Phone number is missing. Please go back and retry.');
      return;
    }
    if (_code.length < _length) {
      _showError('Enter the $_length-digit code.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).verifyPhone(
            phoneNumber: phone,
            otp: _code,
          );
      if (!mounted) return;
      final authenticated = ref.read(authControllerProvider).isAuthenticated;
      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified. Please log in.'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number verified.')),
      );
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
    final phone = ref.read(authControllerProvider).pendingPhone;
    try {
      await ref.read(authControllerProvider.notifier).resendOtp(
            purpose: 'registration',
            phoneNumber: phone,
          );
      if (!mounted) return;
      setState(() => _code = '');
      _startTimer();
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
    final phone = ref.watch(authControllerProvider).pendingPhone;
    final display =
        phone == null ? '+254 7XX XXX XXX' : formatKenyanPhone(phone);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: context.qc.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chevron_left, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Verify ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: context.qc.text,
                            ),
                          ),
                          TextSpan(
                            text: 'your number',
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
                    Text(
                      "We've sent a 6-digit code to $display. "
                      'Enter it below to verify your account.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: context.qc.muted,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _otpBoxes(),
                    const SizedBox(height: 28),
                    _resendRow(),
                  ],
                ),
              ),
            ),
            _keypad(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PrimaryButton(
                label: 'Verify',
                color: QcashColors.green,
                onPressed: (_busy || _code.length < _length) ? null : _verify,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _otpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_length, (i) {
        final filled = i < _code.length;
        final active = i == _code.length && !_busy;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 48,
          height: 56,
          decoration: BoxDecoration(
            color: filled
                ? QcashColors.green.withValues(alpha: 0.08)
                : context.qc.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? QcashColors.green
                  : filled
                      ? QcashColors.green.withValues(alpha: 0.4)
                      : context.qc.border,
              width: active ? 1.6 : 1,
            ),
          ),
          child: Center(
            child: Text(
              filled ? _code[i] : '',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.qc.text,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _resendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't get the code? ",
          style: TextStyle(fontSize: 13.5, color: context.qc.muted),
        ),
        if (_secondsLeft > 0)
          Text(
            'Resend in 0:${_secondsLeft.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: context.qc.muted,
            ),
          )
        else
          GestureDetector(
            onTap: _resend,
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: QcashColors.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _keypad() {
    return Column(
      children: [
        _keyRow(['1', '2', '3']),
        _keyRow(['4', '5', '6']),
        _keyRow(['7', '8', '9']),
        _keyRow(['', '0', 'back']),
      ],
    );
  }

  Widget _keyRow(List<String> keys) {
    return Row(
      children: keys.map((k) {
        if (k.isEmpty) {
          return const Expanded(child: SizedBox(height: 62));
        }
        if (k == 'back') {
          return Expanded(
            child: _keyButton(
              icon: Icons.backspace_outlined,
              onTap: _backspace,
            ),
          );
        }
        return Expanded(
          child: _keyButton(label: k, onTap: () => _append(k)),
        );
      }).toList(),
    );
  }

  Widget _keyButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 62,
        child: Center(
          child: label != null
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: context.qc.text,
                  ),
                )
              : Icon(icon, size: 24, color: context.qc.text),
        ),
      ),
    );
  }
}
