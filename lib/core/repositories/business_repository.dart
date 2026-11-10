import '../api/api_client.dart';
import '../models/business.dart';
import '../models/payment_account.dart';

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

  Business _businessFrom(dynamic data) {
    final map = data is Map && data['data'] is Map
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return Business.fromJson(map);
  }
}
