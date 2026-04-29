/// Accès typé aux variables d'environnement injectées via `--dart-define-from-file`.
///
/// Usage : `flutter run --dart-define-from-file=env/dev.env`.
abstract final class Env {
  static const String flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.jeteste.site/api/v1',
  );

  static const String oneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID');

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get isProd => flavor == 'prod';
  static bool get isStaging => flavor == 'staging';
  static bool get isDev => flavor == 'dev';
}
