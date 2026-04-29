/// Toutes les clés de stockage SOE en un seul endroit.
abstract final class StorageKeys {
  // Secure
  static const String authToken = 'auth_token';
  static const String currentUser = 'current_user';
  static const String currentRole = 'current_role';

  // Preferences (non sensible)
  static const String onboardingDone = 'onboarding_done';
  static const String preferredLang = 'preferred_lang';
  static const String onboardingDoneFlag = 'onboarding_done_flag';
  static const String pushEnabled = 'push_enabled';
}
