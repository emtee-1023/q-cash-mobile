import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/business.dart';
import '../../core/providers/business_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/screen_header.dart';
import '../onboarding/business_registration_screen.dart';

class ManageBusinessesScreen extends ConsumerWidget {
  const ManageBusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesProvider);
    final currentId = ref.watch(currentBusinessProvider)?.id;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(title: 'Manage Businesses', showBack: true),
            Expanded(
              child: businessesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: QcashColors.green),
                ),
                error: (error, _) => _ErrorState(
                  message: error.toString(),
                  onRetry: () =>
                      ref.read(businessesProvider.notifier).refresh(),
                ),
                data: (businesses) {
                  return RefreshIndicator(
                    color: QcashColors.green,
                    onRefresh: () =>
                        ref.read(businessesProvider.notifier).refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      children: [
                        Text(
                          'Your businesses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: context.qc.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose the business you want to manage, or add '
                          'another one.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: context.qc.muted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (businesses.isEmpty)
                          const _EmptyState()
                        else
                          ...businesses.map(
                            (business) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _BusinessTile(
                                business: business,
                                selected: business.id == currentId,
                                onTap: () =>
                                    _selectBusiness(context, ref, business),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: 'Add Business',
                          color: QcashColors.green,
                          onPressed: () => _addBusiness(context),
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

  void _selectBusiness(BuildContext context, WidgetRef ref, Business business) {
    ref.read(selectedBusinessIdProvider.notifier).select(business.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Now managing ${business.businessName}.')),
      );
  }

  void _addBusiness(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BusinessRegistrationScreen(isOnboarding: false),
      ),
    );
  }
}

class _BusinessTile extends StatelessWidget {
  const _BusinessTile({
    required this.business,
    required this.selected,
    required this.onTap,
  });

  final Business business;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = business.businessName.trim().isEmpty
        ? 'Q'
        : business.businessName.trim()[0].toUpperCase();
    final subtitle = [
      if (business.typeName != null && business.typeName!.isNotEmpty)
        business.typeName!,
      if (business.status.isNotEmpty) _titleCase(business.status),
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? QcashColors.green.withValues(alpha: 0.08)
              : context.qc.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? QcashColors.green.withValues(alpha: 0.5)
                : context.qc.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? QcashColors.green.withValues(alpha: 0.15)
                    : context.qc.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: selected ? QcashColors.green : context.qc.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.businessName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.qc.text,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: context.qc.muted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              const Icon(Icons.check_circle, color: QcashColors.green, size: 20)
            else
              Icon(Icons.chevron_right, color: context.qc.muted),
          ],
        ),
      ),
    );
  }

  String _titleCase(String value) {
    return value
        .split(RegExp(r'[_\s]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.qc.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.storefront_outlined, size: 40, color: context.qc.muted),
          const SizedBox(height: 12),
          Text(
            'No businesses yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: context.qc.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a business to start collecting payments with Q-Cash.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.qc.muted),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

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
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: QcashColors.green),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
