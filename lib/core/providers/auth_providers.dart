import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'providers.dart';

class AuthState {
  const AuthState({
    this.token,
    this.challengeToken,
    this.pendingPhone,
  });

  final String? token;
  final String? challengeToken;
  final String? pendingPhone;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    String? token,
    String? challengeToken,
    String? pendingPhone,
    bool clearChallenge = false,
    bool clearPendingPhone = false,
  }) {
    return AuthState(
      token: token ?? this.token,
      challengeToken: clearChallenge ? null : (challengeToken ?? this.challengeToken),
      pendingPhone: clearPendingPhone ? null : (pendingPhone ?? this.pendingPhone),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final token = ref.read(apiClientProvider).token;
    return AuthState(token: token);
  }

  Future<String> register({
    required String name,
    required String phoneNumber,
    required String password,
    required String passwordConfirmation,
  }) async {
    final message = await ref.read(authRepositoryProvider).register(
          name: name,
          phoneNumber: phoneNumber,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
    state = state.copyWith(pendingPhone: phoneNumber);
    return message;
  }

  Future<String> verifyPhone({required String phoneNumber, required String otp}) async {
    final message = await ref.read(authRepositoryProvider).verifyPhone(
          phoneNumber: phoneNumber,
          otp: otp,
        );
    state = state.copyWith(clearPendingPhone: true);
    return message;
  }

  Future<String> resendOtp({
    required String purpose,
    String? phoneNumber,
    String? challengeToken,
  }) {
    return ref.read(authRepositoryProvider).resendOtp(
          purpose: purpose,
          phoneNumber: phoneNumber,
          challengeToken: challengeToken,
        );
  }

  /// Returns `true` when two-factor verification is required before login
  /// completes.
  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    final result = await ref.read(authRepositoryProvider).login(
          phoneNumber: phoneNumber,
          password: password,
        );
    if (result.requiresTwoFactor) {
      state = state.copyWith(challengeToken: result.challengeToken);
      return true;
    }
    state = state.copyWith(token: result.token, clearChallenge: true);
    return false;
  }

  Future<void> verifyTwoFactor({required String otp}) async {
    final challenge = state.challengeToken;
    if (challenge == null) throw StateError('No pending two-factor challenge');
    await ref.read(authRepositoryProvider).verifyTwoFactor(
          challengeToken: challenge,
          otp: otp,
        );
    state = state.copyWith(
      token: ref.read(apiClientProvider).token,
      clearChallenge: true,
    );
  }

  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Token is still cleared locally on the client.
    }
    state = const AuthState();
  }

  Future<String> forgotPassword({required String phoneNumber}) {
    return ref.read(authRepositoryProvider).forgotPassword(phoneNumber: phoneNumber);
  }

  Future<String> resetPassword({
    required String phoneNumber,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) {
    return ref.read(authRepositoryProvider).resetPassword(
          phoneNumber: phoneNumber,
          otp: otp,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );
  }

  Future<User> loadUser() => ref.read(authRepositoryProvider).user();
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

final isAuthenticatedProvider =
    Provider<bool>((ref) => ref.watch(authControllerProvider).isAuthenticated);

final userProvider = FutureProvider<User?>((ref) async {
  if (!ref.watch(authControllerProvider).isAuthenticated) return null;
  return ref.watch(authRepositoryProvider).user();
});
