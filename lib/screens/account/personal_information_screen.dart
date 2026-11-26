import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers/auth_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cards.dart';
import '../../widgets/screen_header.dart';
import 'edit_email_screen.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Personal Information', showBack: true),
            Expanded(
              child: userAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: QcashColors.green),
                ),
                error: (error, _) => _ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(userProvider),
                ),
                data: (user) {
                  if (user == null) {
                    return const _ErrorState(
                      message: 'Your profile is not available right now.',
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InfoCard(
                          children: [
                            KeyValueRow(
                              label: 'Full Name',
                              value: user.name.isEmpty ? '—' : user.name,
                            ),
                            KeyValueRow(
                              label: 'Phone',
                              value: formatKenyanPhone(user.phoneNumber),
                            ),
                            KeyValueRow(
                              label: 'Phone Status',
                              value: user.isPhoneVerified
                                  ? 'Verified'
                                  : 'Unverified',
                              valueColor: user.isPhoneVerified
                                  ? QcashColors.green
                                  : QcashColors.orange,
                            ),
                            KeyValueRow(
                              label: 'ID Type',
                              value: _idTypeLabel(user.idType),
                            ),
                            KeyValueRow(
                              label: 'ID Number',
                              value: user.identificationNumber ?? '—',
                            ),
                            KeyValueRow(
                              label: 'Date of Birth',
                              value: formatDmy(user.dateOfBirth),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _EmailCard(
                          email: user.email,
                          verified: user.isEmailVerified,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditEmailScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const CalloutBox(
                          text:
                              'You can update your email here. Contact support '
                              'to change your name, phone number or ID details.',
                          icon: Icons.lock_outline,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _idTypeLabel(String? idType) {
    switch (idType) {
      case 'kenyan_national_id':
        return 'National ID';
      case 'passport':
        return 'Passport';
      default:
        return idType ?? '—';
    }
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard({
    required this.email,
    required this.verified,
    required this.onTap,
  });

  final String? email;
  final bool verified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color: verified
                    ? QcashColors.green.withValues(alpha: 0.12)
                    : QcashColors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                verified
                    ? Icons.mark_email_read_outlined
                    : Icons.mark_email_unread_outlined,
                size: 20,
                color: verified ? QcashColors.green : QcashColors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email ?? 'Add your email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.qc.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    verified
                        ? 'Email verified'
                        : 'Not verified — tap to verify',
                    style: TextStyle(
                      fontSize: 12,
                      color: verified ? QcashColors.green : QcashColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.qc.muted),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: context.qc.muted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.qc.muted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: QcashColors.green,
                ),
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
