import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_config.dart';

/// Thrown for any API-level failure with a user-facing message extracted
/// from the Laravel JSON error body.
class ApiException implements Exception {
  ApiException(this.message, {this.errors});

  final String message;
  final Map<String, dynamic>? errors;

  /// Flattens the validation `errors` map into a readable string, falling
  /// back to [message].
  String get readable {
    if (errors != null && errors!.isNotEmpty) {
      final lines = <String>[];
      errors!.forEach((key, value) {
        if (value is List) {
          for (final v in value) {
            lines.add('$key: $v');
          }
        } else {
          lines.add('$key: $value');
        }
      });
      return lines.join('\n');
    }
    return message;
  }

  @override
  String toString() => readable;
}

class ApiClient {
  ApiClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    _token = _prefs.getString(_tokenKey);
  }

  static const _tokenKey = 'qcash.auth_token';

  final SharedPreferences _prefs;
  late final Dio _dio;
  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> setToken(String? token) async {
    _token = token;
    if (token == null) {
      await _prefs.remove(_tokenKey);
    } else {
      await _prefs.setString(_tokenKey, token);
    }
  }

  Options get _authOptions => Options(headers: {
        if (_token != null) 'Authorization': 'Bearer $_token',
      });

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) {
    return _guard(() => _dio.get<T>(
          path,
          queryParameters: query,
          options: auth ? _authOptions : null,
        ));
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    bool auth = true,
  }) {
    return _guard(() => _dio.post<T>(
          path,
          data: data,
          options: auth ? _authOptions : null,
        ));
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  ApiException _toApiException(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      final errors = data['errors'];
      return ApiException(
        message ?? 'Request failed',
        errors: errors is Map<String, dynamic> ? errors : null,
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException('Could not reach the server. Check your connection.');
      default:
        return ApiException('Something went wrong (${e.response?.statusCode}).');
    }
  }
}
