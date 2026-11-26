import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/providers/auth_providers.dart';
import 'package:mobile/core/providers/providers.dart';
import 'package:mobile/core/repositories/auth_repository.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient(this.response);

  final Map<String, dynamic> response;
  String? _storedToken;

  @override
  String? get token => _storedToken;

  @override
  bool get isAuthenticated => _storedToken != null && _storedToken!.isNotEmpty;

  @override
  Stream<void> get onUnauthorized => const Stream.empty();

  @override
  Future<void> setToken(String? token) async {
    _storedToken = token;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    bool auth = true,
  }) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: response as T,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) => throw UnimplementedError();

  @override
  Future<Response<T>> patch<T>(String path, {Object? data, bool auth = true}) =>
      throw UnimplementedError();

  @override
  void dispose() {}
}

void main() {
  test('verifyPhone stores the token and authenticates the user', () async {
    final client = _FakeApiClient({
      'message': 'Phone number verified successfully.',
      'token': 'plain-text-token',
      'token_type': 'Bearer',
    });
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        authRepositoryProvider.overrideWithValue(AuthRepository(client)),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(authControllerProvider.notifier)
        .verifyPhone(phoneNumber: '254712345678', otp: '123456');

    expect(client.token, 'plain-text-token');
    expect(container.read(authControllerProvider).isAuthenticated, isTrue);
  });
}
