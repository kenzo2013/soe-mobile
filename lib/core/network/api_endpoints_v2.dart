/// Paths of the API v2 (relative to `Env.apiV2BaseUrl`). Contract: soe/docs/api/v2/openapi.yml.
abstract final class ApiEndpointsV2 {
  /// The signed-in account: identity, language, roles, active role.
  static const String me = '/me';

  // Authentication (AUT-02 to AUT-11).
  static const String session = '/auth/session';
  static const String signUpValidate = '/auth/registrations/validate';
  static const String signUp = '/auth/registrations';
  static const String confirmation = '/auth/confirmations';
  static const String confirmationResend = '/auth/confirmations/resend';
  static const String passwordReset = '/auth/password_resets';
  static const String passwordResetVerify = '/auth/password_resets/verify';
  static const String passwordResetResend = '/auth/password_resets/resend';
}
