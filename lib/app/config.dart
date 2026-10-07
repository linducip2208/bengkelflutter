// Environments: dev/staging/prod via --dart-define.
// APP_ENV=dev|staging|prod, API_BASE_URL override per env.
// ignore_for_file: avoid_classes_with_only_static_members
abstract final class AppConfig {
  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://bengkel-paten.local/api/v1',
  );
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
  static const sendTimeout = Duration(seconds: 30);
  static const maxUploadBytes = 5 * 1024 * 1024;
  static const pageSize = 20;
  static const searchDebounceMs = 400;
  static bool get isProd => env == 'prod';
  static bool get isDev => env == 'dev';
}
