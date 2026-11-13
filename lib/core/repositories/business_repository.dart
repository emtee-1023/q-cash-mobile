import '../api/api_client.dart';
import '../models/business.dart';
import '../models/business_type.dart';
import '../models/location.dart';
import '../models/payment_account.dart';
import '../models/wallet.dart';

class BusinessRepository {
  BusinessRepository(this._client);

  final ApiClient _client;

  Future<List<Business>> list() async {
    final res = await _client.get('/businesses');
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Business.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<Business> show(int id) async {
    final res = await _client.get('/businesses/$id');
    return _businessFrom(res.data);
  }

  Future<Business> create(Map<String, dynamic> payload) async {
    final res = await _client.post('/businesses', data: payload);
    return _businessFrom(res.data);
  }

  Future<Business> update(int id, Map<String, dynamic> payload) async {
    final res = await _client.patch('/businesses/$id', data: payload);
    return _businessFrom(res.data);
  }

  // ---- Business types ----

  Future<List<BusinessType>> listBusinessTypes() async {
    final res = await _client.get('/business-types');
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => BusinessType.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  // ---- Locations ----

  Future<List<County>> listCounties() async {
    final res = await _client.get('/locations/counties');
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => County.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<List<SubCounty>> listSubCounties(int countyId) async {
    final res = await _client.get('/locations/counties/$countyId/sub-counties');
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => SubCounty.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<List<Ward>> listWards(int subCountyId) async {
    final res = await _client.get('/locations/sub-counties/$subCountyId/wards');
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Ward.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  // ---- Payment accounts ----

  Future<PaymentAccount> addPaymentAccount(
    int businessId,
    Map<String, dynamic> payload,
  ) async {
    final res = await _client.post(
      '/businesses/$businessId/payment-accounts',
      data: payload,
    );
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return PaymentAccount.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected payment account payload');
  }

  // ---- Wallet & withdrawals ----

  Future<BusinessWallet> getWallet(int businessId) async {
    final res = await _client.get('/businesses/$businessId/wallet');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return BusinessWallet.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected wallet payload');
  }

  Future<List<Withdrawal>> listWithdrawals(
    int businessId, {
    int perPage = 50,
  }) async {
    final res = await _client.get(
      '/businesses/$businessId/withdrawals',
      query: {'per_page': perPage},
    );
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => Withdrawal.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return const [];
  }

  Future<Withdrawal> createWithdrawal(int businessId, int amountMinor) async {
    final res = await _client.post(
      '/businesses/$businessId/withdrawals',
      data: {'amount_minor': amountMinor},
    );
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Withdrawal.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected withdrawal payload');
  }

  Business _businessFrom(dynamic data) {
    final map = data is Map && data['data'] is Map
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return Business.fromJson(map);
  }
}
