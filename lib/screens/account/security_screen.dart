import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/format.dart';
import '../../core/models/user.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/cards.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/screen_header.dart';
import '../auth/forgot_password_screen.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

enum _SecurityStep { overview, enableTwoFactor, disableTwoFactor }

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _password = TextEditingController();
  _SecurityStep _step = _SecurityStep.overview;
  String _code = '';
  bool _busy = false;
  bool _obscure = true;
  int _otpRound = 0;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _startEnable() async {
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).enableTwoFactor();
      if (!mounted) return;
      setState(() {
        _code = '';
        _otpRound++;
        _step = _SecurityStep.enableTwoFactor;
      });
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not start two-factor setup. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resendEnableCode() async {
    setState(() => _busy = true);
    try {
      await ref.read(authControllerProvider.notifier).enableTwoFactor();
      if (!mounted) return;
      setState(() {
        _code = '';
        _otpRound++;
      });
      _showInfo('A new code has been sent.');
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not resend the code. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmEnable() async {
    if (_code.length < 6) {
      _showError('Enter the 6-digit code.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .confirmTwoFactor(otp: _code);
      if (!mounted) return;
      setState(() {
        _code = '';
        _step = _SecurityStep.overview;
      });
      _showInfo('Two-factor authentication enabled.');
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not enable two-factor authentication.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disableTwoFactor() async {
    if (_password.text.isEmpty) {
      _showError('Enter your password.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .disableTwoFactor(password: _password.text);
      if (!mounted) return;
      _password.clear();
      setState(() => _step = _SecurityStep.overview);
      _showInfo('Two-factor authentication disabled.');
    } on ApiException catch (e) {
      _showError(e.readable);
    } catch (_) {
      _showError('Could not disable two-factor authentication.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openResetPassword() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Security', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: switch (_step) {
                  _SecurityStep.overview => _overview(user),
                  _SecurityStep.enableTwoFactor => _enableView(user),
                  _SecurityStep.disableTwoFactor => _disableView(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overview(User? user) {
    final phoneVerified = user?.isPhoneVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoCard(
          children: [
            KeyValueRow(
              label: 'Phone',
              value: formatKenyanPhone(user?.phoneNumber),
            ),
            KeyValueRow(
              label: 'Phone Status',
              value: phoneVerified ? 'Verified' : 'Unverified',
              valueColor: phoneVerified
                  ? QcashColors.green
                  : QcashColors.orange,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionLabel('Two-factor authentication'),
        _SecurityAction(
          icon: Icons.verified_user_outlined,
          title: 'Set up two-factor authentication',
          subtitle: 'Receive a 6-digit SMS code each time you log in.',
          onTap: _busy ? null : _startEnable,
        ),
        const SizedBox(height: 10),
        _SecurityAction(
          icon: Icons.lock_open_outlined,
          title: 'Turn off two-factor authentication',
          subtitle: 'Requires your account password.',
          onTap: _busy
              ? null
              : () => setState(() {
                  _password.clear();
                  _step = _SecurityStep.disableTwoFactor;
                }),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Password'),
        _SecurityAction(
          icon: Icons.password_outlined,
          title: 'Reset password',
          subtitle:
              "We'll send a code to your phone. Resetting signs you out "
              'everywhere.',
          onTap: _openResetPassword,
        ),
      ],
    );
  }

  Widget _enableView(User? user) {
    final phone = formatKenyanPhone(user?.phoneNumber);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CalloutBox(
          text:
              'Enter the 6-digit code sent to $phone to turn on '
              'two-factor authentication.',
          icon: Icons.sms_outlined,
        ),
        const SizedBox(height: 24),
        const SectionLabel('Verification code'),
        OtpInput(key: ValueKey(_otpRound), onChanged: (code) => _code = code),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _resendEnableCode,
            child: const Text(
              'Resend code',
              style: TextStyle(
                color: QcashColors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Verify & enable',
          color: QcashColors.green,
          onPressed: _busy ? null : _confirmEnable,
        ),
        Center(
          child: TextButton(
            onPressed: _busy
                ? null
                : () => setState(() => _step = _SecurityStep.overview),
            child: Text('Cancel', style: TextStyle(color: context.qc.muted)),
          ),
        ),
      ],
    );
  }

  Widget _disableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CalloutBox(
          text:
              'Enter your account password to turn off two-factor '
              'authentication.',
          icon: Icons.password_outlined,
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _password,
          obscureText: _obscure,
          suffix: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              size: 20,
              color: context.qc.muted,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 8),
        PrimaryButton(
          label: 'Turn off two-factor authentication',
          color: QcashColors.green,
          onPressed: _busy ? null : _disableTwoFactor,
        ),
        Center(
          child: TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                    _password.clear();
                    _step = _SecurityStep.overview;
                  }),
            child: Text('Cancel', style: TextStyle(color: context.qc.muted)),
          ),
        ),
      ],
    );
  }
}

class _SecurityAction extends StatelessWidget {
  const _SecurityAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.qc.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: QcashColors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: QcashColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.qc.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: context.qc.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: context.qc.muted),
          ],
        ),
      ),
    );
  }
}
