import 'package:dio/dio.dart';

import '../../storage/secure_storage.dart';
import '../../storage/storage_keys.dart';

/// Injecte automatiquement `Authorization: Bearer <token>` sur toutes les requêtes.
///
/// Sur 401 : déclenche `onUnauthorized` (logout + redirect vers /login).
/// Plus jamais besoin de passer `requiresAuth` manuellement.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.storage,
    required this.onUnauthorized,
  });

  final SecureStorage storage;
  final Future<void> Function() onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await onUnauthorized();
    }
    handler.next(err);
  }
}
