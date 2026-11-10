import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/advance.dart';
import '../models/assessment.dart';
import '../models/offer.dart';
import '../models/transaction.dart';
import 'providers.dart';

final transactionsProvider = FutureProvider.autoDispose
    .family<List<Transaction>, int>((ref, businessId) async {
  return ref.watch(financeRepositoryProvider).listTransactions(businessId);
});

final advancesProvider = FutureProvider.autoDispose
    .family<List<Advance>, int>((ref, businessId) async {
  return ref.watch(financeRepositoryProvider).listAdvances(businessId);
});

class AccessState {
  const AccessState({
    this.assessment,
    this.offer,
    this.advance,
    this.loading = false,
  });

  final Assessment? assessment;
  final Offer? offer;
  final Advance? advance;
  final bool loading;

  AccessState copyWith({
    Assessment? assessment,
    Offer? offer,
    Advance? advance,
    bool? loading,
    bool clearAssessment = false,
    bool clearOffer = false,
    bool clearAdvance = false,
  }) {
    return AccessState(
      assessment: clearAssessment ? null : (assessment ?? this.assessment),
      offer: clearOffer ? null : (offer ?? this.offer),
      advance: clearAdvance ? null : (advance ?? this.advance),
      loading: loading ?? this.loading,
    );
  }
}

class AccessController extends Notifier<AccessState> {
  @override
  AccessState build() => const AccessState();

  Future<Assessment> requestAssessment(int businessId) async {
    state = state.copyWith(loading: true);
    try {
      final assessment =
          await ref.read(financeRepositoryProvider).requestAssessment(businessId);
      state = state.copyWith(
        loading: false,
        assessment: assessment,
        clearOffer: true,
        clearAdvance: true,
      );
      return assessment;
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  Future<Offer> createOffer(
    int businessId, {
    int? feeAmountMinor,
    int? expiresInDays,
  }) async {
    final assessment = state.assessment;
    if (assessment == null) throw StateError('No assessment available');
    state = state.copyWith(loading: true);
    try {
      final offer = await ref.read(financeRepositoryProvider).createOffer(
            businessId,
            assessmentId: assessment.id,
            feeAmountMinor: feeAmountMinor,
            expiresInDays: expiresInDays,
          );
      state = state.copyWith(loading: false, offer: offer);
      return offer;
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  Future<Advance> acceptOffer() async {
    final offer = state.offer;
    if (offer == null) throw StateError('No offer available');
    state = state.copyWith(loading: true);
    try {
      final advance = await ref.read(financeRepositoryProvider).acceptOffer(offer.id);
      state = state.copyWith(loading: false, advance: advance);
      return advance;
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  Future<Advance> disburse() async {
    final advance = state.advance;
    if (advance == null) throw StateError('No advance available');
    state = state.copyWith(loading: true);
    try {
      final updated = await ref.read(financeRepositoryProvider).disburseAdvance(advance.id);
      state = state.copyWith(loading: false, advance: updated);
      return updated;
    } catch (_) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  void reset() => state = const AccessState();
}

final accessControllerProvider =
    NotifierProvider.autoDispose<AccessController, AccessState>(AccessController.new);
