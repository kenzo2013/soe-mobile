import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/network/interceptors/retry_interceptor.dart';

class _MockDio extends Mock implements Dio {}

class _MockErrHandler extends Mock implements ErrorInterceptorHandler {}

DioException _err({
  required DioExceptionType type,
  int? statusCode,
  RequestOptions? options,
}) {
  final opts = options ?? RequestOptions(path: '/foo');
  return DioException(
    requestOptions: opts,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(requestOptions: opts, statusCode: statusCode),
  );
}

void main() {
  late _MockDio dio;
  late _MockErrHandler handler;
  late RetryInterceptor interceptor;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/')),
    );
    registerFallbackValue(
      Response<dynamic>(requestOptions: RequestOptions(path: '/')),
    );
  });

  setUp(() {
    dio = _MockDio();
    handler = _MockErrHandler();
    // maxRetries plus court pour des tests rapides; les délais restent
    // 300ms * 2^attempt mais on minimise le nombre d'itérations.
    interceptor = RetryInterceptor(dio, maxRetries: 2);
  });

  group('_shouldRetry (pas de retry → next)', () {
    test('ne retry pas sur cancel', () async {
      final err = _err(type: DioExceptionType.cancel);

      await interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => dio.fetch<dynamic>(any()));
    });

    test('ne retry pas sur badCertificate', () async {
      final err = _err(type: DioExceptionType.badCertificate);

      await interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => dio.fetch<dynamic>(any()));
    });

    test('ne retry pas sur unknown', () async {
      final err = _err(type: DioExceptionType.unknown);

      await interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => dio.fetch<dynamic>(any()));
    });

    test('ne retry pas sur badResponse 4xx', () async {
      final err = _err(type: DioExceptionType.badResponse, statusCode: 404);

      await interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => dio.fetch<dynamic>(any()));
    });
  });

  group('_shouldRetry (retry → fetch)', () {
    test('retry sur badResponse 5xx et resolve en cas de succès', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(
        type: DioExceptionType.badResponse,
        statusCode: 503,
        options: opts,
      );
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      verify(() => dio.fetch<dynamic>(any())).called(1);
      verify(() => handler.resolve(ok)).called(1);
    });

    test('retry sur connectionTimeout', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(
        type: DioExceptionType.connectionTimeout,
        options: opts,
      );
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      verify(() => handler.resolve(ok)).called(1);
    });

    test('retry sur sendTimeout', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(type: DioExceptionType.sendTimeout, options: opts);
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      verify(() => handler.resolve(ok)).called(1);
    });

    test('retry sur receiveTimeout', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(type: DioExceptionType.receiveTimeout, options: opts);
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      verify(() => handler.resolve(ok)).called(1);
    });

    test('retry sur connectionError', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(type: DioExceptionType.connectionError, options: opts);
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      verify(() => handler.resolve(ok)).called(1);
    });

    test('incrémente le compteur de retry dans extra', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(type: DioExceptionType.connectionError, options: opts);
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      expect(opts.extra['retry_count'], 1);
    });

    test('relaie la nouvelle erreur via next si le retry échoue', () async {
      final opts = RequestOptions(path: '/foo');
      final err = _err(type: DioExceptionType.connectionError, options: opts);
      final retryErr = _err(
        type: DioExceptionType.connectionError,
        options: opts,
      );
      when(() => dio.fetch<dynamic>(any())).thenThrow(retryErr);

      await interceptor.onError(err, handler);

      verify(() => handler.next(retryErr)).called(1);
      verifyNever(() => handler.resolve(any()));
    });
  });

  group('limite de tentatives', () {
    test('passe à next sans fetch quand attempts >= maxRetries', () async {
      final opts = RequestOptions(path: '/foo')..extra['retry_count'] = 2;
      final err = _err(
        type: DioExceptionType.connectionError,
        options: opts,
      );

      await interceptor.onError(err, handler);

      verify(() => handler.next(err)).called(1);
      verifyNever(() => dio.fetch<dynamic>(any()));
    });

    test('fetch encore quand attempts < maxRetries', () async {
      final opts = RequestOptions(path: '/foo')..extra['retry_count'] = 1;
      final err = _err(
        type: DioExceptionType.connectionError,
        options: opts,
      );
      final ok = Response<dynamic>(requestOptions: opts, statusCode: 200);
      when(() => dio.fetch<dynamic>(any())).thenAnswer((_) async => ok);

      await interceptor.onError(err, handler);

      verify(() => dio.fetch<dynamic>(any())).called(1);
      expect(opts.extra['retry_count'], 2);
    });
  });
}
