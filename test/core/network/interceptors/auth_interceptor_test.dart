import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/network/interceptors/auth_interceptor.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

class _MockReqHandler extends Mock implements RequestInterceptorHandler {}

class _MockErrHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late _MockSecureStorage storage;
  late _MockReqHandler reqHandler;
  late _MockErrHandler errHandler;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(
      DioException(requestOptions: RequestOptions(path: '/')),
    );
  });

  setUp(() {
    storage = _MockSecureStorage();
    reqHandler = _MockReqHandler();
    errHandler = _MockErrHandler();
  });

  AuthInterceptor build({
    required Future<void> Function() onUnauthorized,
  }) =>
      AuthInterceptor(storage: storage, onUnauthorized: onUnauthorized);

  group('onRequest', () {
    test('ajoute le header Authorization quand un token est présent', () async {
      when(() => storage.read(StorageKeys.authToken))
          .thenAnswer((_) async => 'abc123');
      final interceptor = build(onUnauthorized: () async {});
      final options = RequestOptions(path: '/foo');

      await interceptor.onRequest(options, reqHandler);

      expect(options.headers['Authorization'], 'Bearer abc123');
      verify(() => reqHandler.next(options)).called(1);
    });

    test('n\'ajoute pas de header quand le token est null', () async {
      when(() => storage.read(StorageKeys.authToken))
          .thenAnswer((_) async => null);
      final interceptor = build(onUnauthorized: () async {});
      final options = RequestOptions(path: '/foo');

      await interceptor.onRequest(options, reqHandler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => reqHandler.next(options)).called(1);
    });

    test('n\'ajoute pas de header quand le token est vide', () async {
      when(() => storage.read(StorageKeys.authToken))
          .thenAnswer((_) async => '');
      final interceptor = build(onUnauthorized: () async {});
      final options = RequestOptions(path: '/foo');

      await interceptor.onRequest(options, reqHandler);

      expect(options.headers.containsKey('Authorization'), isFalse);
      verify(() => reqHandler.next(options)).called(1);
    });

    test('lit bien la clé authToken', () async {
      when(() => storage.read(StorageKeys.authToken))
          .thenAnswer((_) async => 'tok');
      final interceptor = build(onUnauthorized: () async {});

      await interceptor.onRequest(RequestOptions(path: '/foo'), reqHandler);

      verify(() => storage.read(StorageKeys.authToken)).called(1);
    });
  });

  group('onError', () {
    test('déclenche onUnauthorized sur 401', () async {
      var called = false;
      final interceptor = build(onUnauthorized: () async {
        called = true;
      });
      final err = DioException(
        requestOptions: RequestOptions(path: '/foo'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/foo'),
          statusCode: 401,
        ),
      );

      await interceptor.onError(err, errHandler);

      expect(called, isTrue);
      verify(() => errHandler.next(err)).called(1);
    });

    test('ne déclenche pas onUnauthorized sur un autre statut', () async {
      var called = false;
      final interceptor = build(onUnauthorized: () async {
        called = true;
      });
      final err = DioException(
        requestOptions: RequestOptions(path: '/foo'),
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/foo'),
          statusCode: 500,
        ),
      );

      await interceptor.onError(err, errHandler);

      expect(called, isFalse);
      verify(() => errHandler.next(err)).called(1);
    });

    test('ne déclenche pas onUnauthorized quand response est null', () async {
      var called = false;
      final interceptor = build(onUnauthorized: () async {
        called = true;
      });
      final err = DioException(
        requestOptions: RequestOptions(path: '/foo'),
        type: DioExceptionType.connectionError,
      );

      await interceptor.onError(err, errHandler);

      expect(called, isFalse);
      verify(() => errHandler.next(err)).called(1);
    });
  });
}
