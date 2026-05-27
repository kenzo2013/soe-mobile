import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../env/env.dart';

/// Logger HTTP simple. Désactivé en prod.
///
/// En dev : log la méthode + l'URI sur chaque requête, et le body de la
/// réponse sur succès comme erreur (utile pour debug parsing / payload).
/// Bodies binaires (FormData, bytes) sont labelés pour éviter de polluer.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);
  final Logger _logger;

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    if (!Env.isProd) {
      _logger.d('→ ${o.method} ${o.uri}');
      final reqBody = o.data;
      if (reqBody != null) {
        _logger.d('  request body  : ${_pretty(reqBody)}');
      }
    }
    h.next(o);
  }

  @override
  void onResponse(Response<dynamic> r, ResponseInterceptorHandler h) {
    if (!Env.isProd) {
      _logger.d('← ${r.statusCode} ${r.requestOptions.uri}');
      final body = r.data;
      if (body != null) {
        _logger.d('  response body : ${_pretty(body)}');
      }
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
      final status = e.response?.statusCode ?? 0;
      if (status >= 400) {
        final reqBody = e.requestOptions.data;
        if (reqBody != null) {
          _logger.w('  request body  : ${_pretty(reqBody)}');
        }
        final respBody = e.response?.data;
        if (respBody != null) {
          _logger.w('  response body : ${_pretty(respBody)}');
        }
      }
    }
    h.next(e);
  }

  /// Stringifie une réponse pour le log. Pour les Map / List on tente un
  /// `jsonEncode` pour avoir une sortie lisible et compacte. Les FormData
  /// et bytes sont labelés (pas de dump binaire).
  String _pretty(dynamic body) {
    if (body is FormData) {
      final fields = body.fields.map((e) => '${e.key}=${e.value}').join(', ');
      final files = body.files.map((e) => e.key).join(', ');
      return '<FormData fields=[$fields] files=[$files]>';
    }
    if (body is List<int>) return '<bytes ${body.length}>';
    if (body is String && body.length > 1000) {
      return '${body.substring(0, 1000)}… <${body.length} chars>';
    }
    try {
      return jsonEncode(body);
    } catch (_) {
      return body.toString();
    }
  }
}
