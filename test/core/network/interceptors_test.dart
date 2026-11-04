import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/network/interceptors/logging_interceptor.dart';
import 'package:soe/core/network/interceptors/retry_interceptor.dart';

class _Handler extends ErrorInterceptorHandler {
  DioException? passedOn;

  @override
  void next(DioException err) => passedOn = err;
}

void main() {
  test('passwords, codes and tokens are masked in the logs, at any depth', () {
    final logged = LoggingInterceptor.redact({
      'login': 'awa@example.com',
      'password': 'secret',
      'code': '123456',
      'data': {
        'token': 'jwt',
        'pending_token': 'p',
        'user': {'first_name': 'Awa'},
      },
    }) as Map;

    expect(logged['login'], 'awa@example.com');
    expect(logged['password'], '[FILTERED]');
    expect(logged['code'], '[FILTERED]');
    expect(logged['data'], {
      'token': '[FILTERED]',
      'pending_token': '[FILTERED]',
      'user': {'first_name': 'Awa'},
    });
  });

  test('a POST that timed out is not replayed (the server may have handled it)',
      () async {
    var calls = 0;
    final dio = Dio()..httpClientAdapter = _CountingAdapter(() => calls++);
    final handler = _Handler();
    final error = DioException(
      requestOptions:
          RequestOptions(path: '/auth/confirmations', method: 'POST'),
      type: DioExceptionType.receiveTimeout,
    );

    await RetryInterceptor(dio).onError(error, handler);

    expect(calls, 0);
    expect(handler.passedOn, same(error));
  });
}

class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.onFetch);
  final void Function() onFetch;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    onFetch();
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}
