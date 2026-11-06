/// Typed access to the variables injected by `--dart-define-from-file`.
///
/// Usage: `flutter run --target=lib/main_dev.dart --dart-define-from-file=env/dev.env`.
/// There is **no default API URL**: a build without an env file must not talk to staging or
/// production by accident (development runs against the local Rails server, through a tunnel).
abstract final class Env {
  static const String flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  /// Address of the SOE API, e.g. `https://my-tunnel.trycloudflare.com`. The app only calls
  /// the API v2 (see [apiV2BaseUrl]); a former `…/api/v1` address is still accepted, so that the
  /// existing env files keep working.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// API v2 base URL, the only one the app calls: [apiBaseUrl]'s origin + `/api/v2`; empty when
  /// unusable.
  static String get apiV2BaseUrl => v2BaseUrlFrom(apiBaseUrl) ?? '';

  static const String oneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID');

  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Google Places key (Maps + Places SDK): `--dart-define=GOOGLE_PLACES_API_KEY=...`.
  static const String googlePlacesApiKey =
      String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  /// `prd` is what scripts/build.sh passes (Doppler config name); `prod` is the former value.
  static bool get isProd => flavor == 'prd' || flavor == 'prod';

  /// `stg` is what scripts/build.sh passes (the « SOE Test » app); `staging` is the former value.
  static bool get isStaging => flavor == 'stg' || flavor == 'staging';
  static bool get isDev => flavor == 'dev';

  /// Throws a [StateError] with the command to run when the API URL is missing or unusable.
  static void ensureConfigured([String url = apiBaseUrl]) {
    if (url.isEmpty || v2BaseUrlFrom(url) == null) {
      throw StateError(
        'API_BASE_URL is missing or invalid ("$url"). Expected https://<host> (or https://<host>/api/v1). '
        'Run with --dart-define-from-file=env/dev.env (see env/example.env; development uses '
        'the local server, never staging).',
      );
    }
  }

  /// `https://host` (or the former `https://host/api/v1`) -> `https://host/api/v2`; anything
  /// else -> null.
  static String? v2BaseUrlFrom(String apiUrl) {
    final uri = Uri.tryParse(apiUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    final path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    if (path.isNotEmpty && path != '/api/v1') return null;
    return uri
        .replace(path: '/api/v2', query: null, fragment: null)
        .toString()
        .replaceFirst(RegExp(r'\?$'), '');
  }

  /// `scheme://host[:port]` of the API, or null when not configured.
  static String? get apiOrigin {
    final uri = Uri.tryParse(apiBaseUrl);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty
        ? uri.origin
        : null;
  }
}
