import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../env/env.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/locale_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Construit l'instance Dio configurée pour l'API SOE.
///
/// Aucun `badCertificateCallback` qui retourne `true` (cf. REBUILD_SPEC §8.1).
class HttpClientFactory {
  static Dio create({
    required SecureStorage storage,
    required Logger logger,
    required Future<void> Function() onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      const LocaleInterceptor(),
      AuthInterceptor(storage: storage, onUnauthorized: onUnauthorized),
      RetryInterceptor(dio),
      const ErrorInterceptor(),
      LoggingInterceptor(logger),
    ]);

    return dio;
  }
}
