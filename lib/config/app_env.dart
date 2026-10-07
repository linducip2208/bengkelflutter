// Centralized config. Jangan hardcode production URL di banyak tempat.
// ignore_for_file: avoid_classes_with_only_static_members
abstract final class AppEnv {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://bengkel-paten.local/api/v1',
  );
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 30);
  static const maxUploadBytes = 5 * 1024 * 1024; // hormati backend max upload
}
