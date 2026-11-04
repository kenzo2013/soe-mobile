import 'dart:async';

import 'package:dio/dio.dart';

/// Retry exponentiel sur erreurs réseau et 5xx (max 3 tentatives).
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 3});

  final Dio _dio;
  final int maxRetries;

  static const String _retryCountKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final attempts = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (attempts >= maxRetries) {
      return handler.next(err);
    }

    final delay = Duration(milliseconds: 300 * (1 << attempts));
    await Future<void>.delayed(delay);

    final nextOptions = err.requestOptions
      ..extra[_retryCountKey] = attempts + 1;

    try {
      final response = await _dio.fetch<dynamic>(nextOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Only reads are replayed: a POST or PUT may have reached the server before the
  /// timeout (a code already used, an account already created).
  static const _replayableMethods = {'GET', 'HEAD', 'OPTIONS'};

  bool _shouldRetry(DioException e) {
    if (!_replayableMethods.contains(e.requestOptions.method.toUpperCase())) {
      return false;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        return code >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }
}
