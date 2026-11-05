/// Toutes les clés de stockage SOE en un seul endroit.
abstract final class StorageKeys {
  // Secure
  static const String authToken = 'auth_token';
  static const String currentUser = 'current_user';
  static const String currentRole = 'current_role';

  /// The OneSignal player id registered with `POST /devices` (unregistered at sign-out).
  static const String pushPlayerId = 'push_player_id';

  // Preferences (non sensible)
  static const String onboardingDone = 'onboarding_done';
  static const String preferredLang = 'preferred_lang';
  static const String onboardingDoneFlag = 'onboarding_done_flag';

  /// Set on the first launch. Preferences are erased when the app is uninstalled, the iOS
  /// keychain is not: without this marker, a reinstall would reopen the previous session.
  static const String installMarker = 'install_marker';
  static const String pushEnabled = 'push_enabled';
}
