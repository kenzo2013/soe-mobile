import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../env/env.dart';

/// Logger HTTP simple. Désactivé en prod.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);
  final Logger _logger;

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (!Env.isProd) {
      _logger.d('→ ${o.method} ${o.uri}');
    }
    h.next(o);
  }

  @override
  void onResponse(Response<dynamic> r, ResponseInterceptorHandler h) {
    if (!Env.isProd) {
      _logger.d('← ${r.statusCode} ${r.requestOptions.uri}');
    }
    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    if (!Env.isProd) {
      _logger.w(
        '✗ ${e.requestOptions.method} ${e.requestOptions.uri} '
        '→ ${e.response?.statusCode} ${e.message}',
      );
      // Sur 4xx/5xx, on log aussi le body envoye + la reponse pour
      // diagnostiquer les 422 (validation Rails) facilement.
      final status = e.response?.statusCode ?? 0;
      if (status >= 400) {
        final reqBody = e.requestOptions.data;
        if (reqBody != null) {
          _logger.w('  request body  : $reqBody');
        }
        final respBody = e.response?.data;
        if (respBody != null) {
          _logger.w('  response body : $respBody');
        }
      }
    }
    h.next(e);
  }
}
