import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/business.dart';
import '../models/business_type.dart';
import '../models/location.dart';
import '../models/wallet.dart';
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

/// The business currently selected by the user (defaults to the first one).
class SelectedBusinessId extends Notifier<int?> {
  static const _key = 'qcash.selected_business_id';

  @override
  int? build() => ref.read(sharedPreferencesProvider).getInt(_key);

  void select(int id) {
    ref.read(sharedPreferencesProvider).setInt(_key, id);
    state = id;
  }
}

final selectedBusinessIdProvider =
    NotifierProvider<SelectedBusinessId, int?>(SelectedBusinessId.new);

/// The business the user is currently acting on.
final currentBusinessProvider = Provider<Business?>((ref) {
  final businesses = ref.watch(businessesProvider).value;
  if (businesses == null || businesses.isEmpty) return null;
  final selectedId = ref.watch(selectedBusinessIdProvider);
  if (selectedId != null) {
    for (final business in businesses) {
      if (business.id == selectedId) return business;
    }
  }
  return businesses.first;
});

final businessTypesProvider = FutureProvider<List<BusinessType>>((ref) async {
  if (!ref.watch(authControllerProvider).isAuthenticated) return const [];
  return ref.watch(businessRepositoryProvider).listBusinessTypes();
});

final countiesProvider = FutureProvider<List<County>>((ref) async {
  if (!ref.watch(authControllerProvider).isAuthenticated) return const [];
  return ref.watch(businessRepositoryProvider).listCounties();
});

final subCountiesProvider =
    FutureProvider.autoDispose.family<List<SubCounty>, int>((ref, countyId) async {
  return ref.watch(businessRepositoryProvider).listSubCounties(countyId);
});

final wardsProvider =
    FutureProvider.autoDispose.family<List<Ward>, int>((ref, subCountyId) async {
  return ref.watch(businessRepositoryProvider).listWards(subCountyId);
});

final walletProvider = FutureProvider.autoDispose
    .family<BusinessWallet, int>((ref, businessId) async {
  return ref.watch(businessRepositoryProvider).getWallet(businessId);
});

/// Fresh business detail from the API (includes paybill / collection account).
final businessDetailProvider = FutureProvider.autoDispose
    .family<Business, int>((ref, businessId) async {
  return ref.watch(businessRepositoryProvider).show(businessId);
});

final withdrawalsProvider = FutureProvider.autoDispose
    .family<List<Withdrawal>, int>((ref, businessId) async {
  return ref.watch(businessRepositoryProvider).listWithdrawals(businessId);
});
