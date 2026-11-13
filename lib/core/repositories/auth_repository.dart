import '../api/api_client.dart';
import '../models/user.dart';

class LoginResult {
  const LoginResult({this.token, this.requiresTwoFactor = false, this.challengeToken});

  final String? token;
  final bool requiresTwoFactor;
  final String? challengeToken;
}

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<String> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
    String? email,
    required String idType,
    required String identificationNumber,
    required String dateOfBirth,
  }) async {
    final res = await _client.post('/auth/register', auth: false, data: {
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'email': ?email,
      'id_type': idType,
      'identification_number': identificationNumber,
      'date_of_birth': dateOfBirth,
    });
    return _message(res.data);
  }

  Future<String> verifyPhone({
    required String phoneNumber,
    required String otp,
  }) async {
    final res = await _client.post('/auth/verify-phone', auth: false, data: {
      'phone_number': phoneNumber,
      'otp': otp,
    });
    return _message(res.data);
  }

  Future<String> resendOtp({
    required String purpose,
    String? phoneNumber,
    String? challengeToken,
  }) async {
    final res = await _client.post('/auth/resend-otp', auth: false, data: {
      'purpose': purpose,
      'phone_number': ?phoneNumber,
      'challenge_token': ?challengeToken,
    });
    return _message(res.data);
  }

  Future<LoginResult> login({
    required String phoneNumber,
    required String password,
  }) async {
    final res = await _client.post('/auth/login', auth: false, data: {
      'phone_number': phoneNumber,
      'password': password,
    });
    final data = res.data;
    if (data is Map && data['token'] != null) {
      final token = data['token'].toString();
      await _client.setToken(token);
      return LoginResult(token: token);
    }
    return LoginResult(
      requiresTwoFactor: true,
      challengeToken: data is Map ? data['challenge_token']?.toString() : null,
    );
  }

  Future<String> verifyTwoFactor({
    required String challengeToken,
    required String otp,
  }) async {
    final res = await _client.post('/auth/2fa/verify', auth: false, data: {
      'challenge_token': challengeToken,
      'otp': otp,
    });
    final token = res.data is Map ? res.data['token']?.toString() : null;
    if (token != null) await _client.setToken(token);
    return _message(res.data);
  }

  Future<String> forgotPassword({required String phoneNumber}) async {
    final res = await _client.post('/auth/forgot-password', auth: false, data: {
      'phone_number': phoneNumber,
    });
    return _message(res.data);
  }

  Future<String> resetPassword({
    required String phoneNumber,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _client.post('/auth/reset-password', auth: false, data: {
      'phone_number': phoneNumber,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    return _message(res.data);
  }

  Future<String> logout() async {
    try {
      final res = await _client.post('/auth/logout');
      return _message(res.data);
    } finally {
      // Always clear the locally persisted session, even if the server call
      // fails, so the user is never silently logged back in on restart.
      await _client.setToken(null);
    }
  }

  Future<User> user() async {
    final res = await _client.get('/auth/user');
    final data = res.data;
    if (data is Map && data['user'] is Map) {
      return User.fromJson(data['user'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected user payload');
  }

  Future<String> enableTwoFactor() async {
    final res = await _client.post('/auth/2fa/enable');
    return _message(res.data);
  }

  Future<String> confirmTwoFactor({required String otp}) async {
    final res = await _client.post('/auth/2fa/confirm', data: {'otp': otp});
    return _message(res.data);
  }

  Future<String> disableTwoFactor({required String password}) async {
    final res = await _client.post('/auth/2fa/disable', data: {'password': password});
    return _message(res.data);
  }

  Future<String> updateProfile({required String email}) async {
    final res = await _client.patch('/user', data: {'email': email});
    return _message(res.data);
  }

  Future<String> sendEmailVerificationCode() async {
    final res = await _client.post('/user/email/verification-code');
    return _message(res.data);
  }

  Future<String> verifyEmail({required String otp}) async {
    final res = await _client.post('/user/email/verify', data: {'otp': otp});
    return _message(res.data);
  }

  String _message(dynamic data) =>
      data is Map ? (data['message']?.toString() ?? '') : '';
}
