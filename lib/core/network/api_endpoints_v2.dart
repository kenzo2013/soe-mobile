/// Paths of the API v2 (relative to `Env.apiV2BaseUrl`). Contract: soe/docs/api/v2/openapi.yml.
abstract final class ApiEndpointsV2 {
  /// The signed-in account: identity, language, roles, active role.
  static const String me = '/me';
}
