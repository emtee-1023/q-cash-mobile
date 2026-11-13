import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_providers.dart';
import '../../core/providers/business_providers.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../onboarding/business_registration_screen.dart';
import 'dashboard_screen.dart';

/// Root widget that routes to login or the dashboard based on the
/// persisted session. The branded launch screen is handled natively.
class AppHome extends ConsumerWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (!auth.isAuthenticated) return const LoginScreen(showBack: false);
    return const _HomeGate();
  }
}

class _HomeGate extends ConsumerWidget {
  const _HomeGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);
    return businesses.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: QcashColors.green),
        ),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load your businesses.\n${error.toString()}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: QcashColors.textGray),
            ),
          ),
        ),
      ),
      data: (list) {
        if (list.isEmpty) return const BusinessRegistrationScreen();
        return const DashboardScreen();
      },
    );
  }
}
