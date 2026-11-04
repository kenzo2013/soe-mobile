/// Typed access to the variables injected by `--dart-define-from-file`.
///
/// Usage: `flutter run --target=lib/main_dev.dart --dart-define-from-file=env/dev.env`.
/// There is **no default API URL**: a build without an env file must not talk to staging or
/// production by accident (development runs against the local Rails server, through a tunnel).
abstract final class Env {
  static const String flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// API v1 base URL, e.g. `https://my-tunnel.trycloudflare.com/api/v1`.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// API v2 base URL, derived from [apiBaseUrl] (same host, `/api/v2`).
  static String get apiV2BaseUrl => v2BaseUrlFrom(apiBaseUrl);

  static const String oneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID');

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Google Places key (Maps + Places SDK): `--dart-define=GOOGLE_PLACES_API_KEY=...`.
  static const String googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  static bool get isProd => flavor == 'prod';
  static bool get isStaging => flavor == 'staging';
  static bool get isDev => flavor == 'dev';

  /// Fails at startup when the API URL is missing, with the command to fix it.
  static void ensureConfigured() {
    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing. Run with --dart-define-from-file=env/dev.env '
        '(see env/example.env; development uses the local server, never staging).',
      );
    }
  }

  /// `https://host/api/v1` -> `https://host/api/v2`; a URL without `/api/v1` gets `/api/v2` appended.
  static String v2BaseUrlFrom(String v1BaseUrl) {
    if (v1BaseUrl.isEmpty) return '';
    final origin = v1BaseUrl
        .replaceFirst(RegExp(r'/api/v1/?$'), '')
        .replaceFirst(RegExp(r'/$'), '');
    return '$origin/api/v2';
  }
}
