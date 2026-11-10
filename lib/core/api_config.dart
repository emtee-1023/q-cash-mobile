class ApiConfig {
  ApiConfig._();

  /// Base URL of the Laravel backend.
  ///
  /// Override at build/run time with:
  ///   flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8006/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://10.53.60.249:8009/api',
    defaultValue: 'http://100.89.180.124:3005/api',
  );
}
