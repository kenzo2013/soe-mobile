import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/network/interceptors/logging_interceptor.dart';

class _MockLogger extends Mock implements Logger {}

class _MockReqHandler extends Mock implements RequestInterceptorHandler {}

class _MockRespHandler extends Mock implements ResponseInterceptorHandler {}

class _MockErrHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late _MockLogger logger;
  late LoggingInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/')),
    );
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/')),
    );
  });

  setUp(() {
    logger = _MockLogger();
    interceptor = LoggingInterceptor(logger);
  });

  // NB: en environnement de test Env.flavor vaut 'dev' (defaultValue), donc
  // Env.isProd == false : toutes les branches de log sont exécutées.

  group('onRequest', () {
    test('appelle handler.next avec les options inchangées', () {
      final options = RequestOptions(path: '/foo', method: 'GET');
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(() => handler.next(options)).called(1);
    });

    test('log la méthode et l\'URI de la requête', () {
      final options = RequestOptions(path: '/foo', method: 'POST');
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(() => logger.d(any<String>(that: contains('POST')))).called(1);
    });

    test('log le body quand data != null', () {
      final options = RequestOptions(
        path: '/foo',
        method: 'POST',
        data: {'a': 1},
      );
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(() => logger.d(any<String>(that: contains('request body'))))
          .called(1);
    });

    test('ne log pas de body quand data == null', () {
      final options = RequestOptions(path: '/foo', method: 'GET');
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verifyNever(() => logger.d(any<String>(that: contains('request body'))));
    });

    test('formate un FormData en label lisible', () {
      final form = FormData()..fields.add(const MapEntry('name', 'kevin'));
      final options = RequestOptions(path: '/foo', method: 'POST', data: form);
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => logger
            .d(any<String>(that: contains('<FormData fields=[name=kevin]'))),
      ).called(1);
    });
  });

  group('onResponse', () {
    test('appelle handler.next avec la réponse', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/foo'),
        statusCode: 200,
        data: {'ok': true},
      );
      final handler = _MockRespHandler();

      interceptor.onResponse(response, handler);

      verify(() => handler.next(response)).called(1);
    });

    test('log le status code et le body', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/foo'),
        statusCode: 200,
        data: {'ok': true},
      );
      final handler = _MockRespHandler();

      interceptor.onResponse(response, handler);

      verify(() => logger.d(any<String>(that: contains('200')))).called(1);
      verify(() => logger.d(any<String>(that: contains('response body'))))
          .called(1);
    });

    test('ne log pas le body quand data == null', () {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/foo'),
        statusCode: 204,
      );
      final handler = _MockRespHandler();

      interceptor.onResponse(response, handler);

      verifyNever(() => logger.d(any<String>(that: contains('response body'))));
    });
  });

  group('onError', () {
    test('appelle handler.next avec l\'erreur', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/foo', method: 'GET'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/foo'),
          statusCode: 500,
        ),
      );
      final handler = _MockErrHandler();

      interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
    });

    test('log un warning avec la méthode et l\'URI', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/foo', method: 'DELETE'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/foo'),
          statusCode: 404,
        ),
      );
      final handler = _MockErrHandler();

      interceptor.onError(err, handler);

      verify(() => logger.w(any<String>(that: contains('DELETE')))).called(1);
    });

    test('log les bodies request/response quand status >= 400', () {
      final reqOpts = RequestOptions(
        path: '/foo',
        method: 'POST',
        data: {'x': 1},
      );
      final err = DioException(
        requestOptions: reqOpts,
        response: Response<dynamic>(
          requestOptions: reqOpts,
          statusCode: 422,
          data: {'error': 'invalid'},
        ),
      );
      final handler = _MockErrHandler();

      interceptor.onError(err, handler);

      verify(() => logger.w(any<String>(that: contains('request body'))))
          .called(1);
      verify(() => logger.w(any<String>(that: contains('response body'))))
          .called(1);
    });

    test('ne log pas les bodies quand status < 400', () {
      final reqOpts = RequestOptions(path: '/foo', method: 'GET');
      final err = DioException(
        requestOptions: reqOpts,
        type: DioExceptionType.cancel,
      );
      final handler = _MockErrHandler();

      interceptor.onError(err, handler);

      verifyNever(() => logger.w(any<String>(that: contains('request body'))));
      verifyNever(() => logger.w(any<String>(that: contains('response body'))));
    });
  });

  group('_pretty (via les logs)', () {
    test('encode un Map en JSON', () {
      final options = RequestOptions(
        path: '/foo',
        method: 'POST',
        data: {'a': 1, 'b': 'two'},
      );
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => logger
            .d(any<String>(that: contains(jsonEncode({'a': 1, 'b': 'two'})))),
      ).called(1);
    });

    test('label les bytes (List<int>)', () {
      final options = RequestOptions(
        path: '/foo',
        method: 'POST',
        data: <int>[1, 2, 3],
      );
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(() => logger.d(any<String>(that: contains('<bytes 3>'))))
          .called(1);
    });

    test('tronque les String de plus de 1000 caractères', () {
      final big = 'a' * 1500;
      final options = RequestOptions(
        path: '/foo',
        method: 'POST',
        data: big,
      );
      final handler = _MockReqHandler();

      interceptor.onRequest(options, handler);

      verify(() => logger.d(any<String>(that: contains('<1500 chars>'))))
          .called(1);
    });
  });
}
