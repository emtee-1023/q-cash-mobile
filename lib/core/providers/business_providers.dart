import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business.dart';
import 'auth_providers.dart';
import 'providers.dart';

final businessesProvider = AsyncNotifierProvider<BusinessListNotifier, List<Business>>(
  BusinessListNotifier.new,
);

class BusinessListNotifier extends AsyncNotifier<List<Business>> {
  @override
  Future<List<Business>> build() async {
    if (!ref.watch(authControllerProvider).isAuthenticated) return const [];
    return ref.watch(businessRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(businessRepositoryProvider).list(),
    );
  }

  Future<Business> create(Map<String, dynamic> payload) async {
    final business = await ref.read(businessRepositoryProvider).create(payload);
    await refresh();
    return business;
  }

  Future<void> addPaymentAccount(int businessId, Map<String, dynamic> payload) async {
    await ref.read(businessRepositoryProvider).addPaymentAccount(businessId, payload);
  }
}

/// The business the user is currently acting on (the first one they own).
final currentBusinessProvider = Provider<Business?>((ref) {
  final businesses = ref.watch(businessesProvider).value;
  if (businesses == null || businesses.isEmpty) return null;
  return businesses.first;
});
