import '../api/api_client.dart';
import '../models/advance.dart';
import '../models/assessment.dart';
import '../models/offer.dart';
import '../models/repayment.dart';
import '../models/transaction.dart';

class FinanceRepository {
  FinanceRepository(this._client);

  final ApiClient _client;

  // ---- Transactions ----

  Future<List<Transaction>> listTransactions(
    int businessId, {
    int perPage = 50,
  }) async {
    final res = await _client.get(
      '/businesses/$businessId/transactions',
      query: {'per_page': perPage},
    );
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  // ---- Assessments ----

  Future<Assessment> requestAssessment(int businessId) async {
    final res = await _client.post('/businesses/$businessId/assessments');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Assessment.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected assessment payload');
  }

  // ---- Offers ----

  Future<Offer> createOffer(
    int businessId, {
    required int assessmentId,
    int? feeAmountMinor,
    int? expiresInDays,
  }) async {
    final res = await _client.post('/businesses/$businessId/offers', data: {
      'assessment_id': assessmentId,
      'fee_amount_minor': ?feeAmountMinor,
      'expires_in_days': ?expiresInDays,
    });
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Offer.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected offer payload');
  }

  Future<Advance> acceptOffer(int offerId, {int? financingPartnerId}) async {
    final res = await _client.post('/offers/$offerId/accept', data: {
      'financing_partner_id': ?financingPartnerId,
    });
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Advance.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected advance payload');
  }

  // ---- Advances ----

  Future<List<Advance>> listAdvances(int businessId) async {
    final res = await _client.get('/businesses/$businessId/advances');
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Advance.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<Advance> showAdvance(int advanceId) async {
    final res = await _client.get('/advances/$advanceId');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Advance.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected advance payload');
  }

  Future<Advance> approveAdvance(int advanceId) async {
    final res = await _client.post('/advances/$advanceId/approve');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Advance.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected advance payload');
  }

  Future<Advance> disburseAdvance(int advanceId) async {
    final res = await _client.post('/advances/$advanceId/disburse');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Advance.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected advance payload');
  }

  // ---- Repayments ----

  Future<RepaymentCollection> recordRepayment(
    int businessId, {
    required String collectionMethod,
    required int amountMinor,
    required String currency,
    required String idempotencyKey,
    required List<Map<String, dynamic>> allocations,
  }) async {
    final res = await _client.post('/businesses/$businessId/repayments', data: {
      'collection_method': collectionMethod,
      'amount_minor': amountMinor,
      'currency': currency,
      'idempotency_key': idempotencyKey,
      'allocations': allocations,
    });
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return RepaymentCollection.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected repayment payload');
  }
}
