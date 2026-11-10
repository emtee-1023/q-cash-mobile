class ApiConfig {
  ApiConfig._();

  /// Base URL of the Laravel backend.
  ///
  /// Override at build/run time with:
  ///   flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8006/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://172.20.10.2:8006/api',
  );
}
