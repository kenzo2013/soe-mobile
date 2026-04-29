import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/exception_mapper.dart';
import 'package:soe/core/error/failure.dart';

DioException _err({
  DioExceptionType type = DioExceptionType.badResponse,
  int? code,
  Object? data,
}) {
  final opts = RequestOptions(path: '/');
  return DioException(
    requestOptions: opts,
    type: type,
    response: code == null
        ? null
        : Response<dynamic>(
            requestOptions: opts,
            statusCode: code,
            data: data,
          ),
  );
}

void main() {
  group('ExceptionMapper.fromDio', () {
    test('connection timeout -> TimeoutFailure', () {
      expect(
        ExceptionMapper.fromDio(_err(type: DioExceptionType.connectionTimeout)),
        isA<TimeoutFailure>(),
      );
    });

    test('connection error -> NetworkFailure', () {
      expect(
        ExceptionMapper.fromDio(_err(type: DioExceptionType.connectionError)),
        isA<NetworkFailure>(),
      );
    });

    test('cancel -> CancelledFailure', () {
      expect(
        ExceptionMapper.fromDio(_err(type: DioExceptionType.cancel)),
        isA<CancelledFailure>(),
      );
    });

    test('400 -> ServerFailure(400)', () {
      final f = ExceptionMapper.fromDio(_err(code: 400));
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).code, 400);
    });

    test('401 -> UnauthorizedFailure', () {
      expect(
          ExceptionMapper.fromDio(_err(code: 401)), isA<UnauthorizedFailure>());
    });

    test('403 -> ForbiddenFailure', () {
      expect(ExceptionMapper.fromDio(_err(code: 403)), isA<ForbiddenFailure>());
    });

    test('404 -> NotFoundFailure', () {
      expect(ExceptionMapper.fromDio(_err(code: 404)), isA<NotFoundFailure>());
    });

    test('409 -> ConflictFailure with message', () {
      final f = ExceptionMapper.fromDio(_err(
        code: 409,
        data: {
          'status': {'code': 409, 'message': 'Already exists'}
        },
      ));
      expect(f, isA<ConflictFailure>());
      expect((f as ConflictFailure).message, 'Already exists');
    });

    test('422 -> ValidationFailure with errors map', () {
      final f = ExceptionMapper.fromDio(_err(
        code: 422,
        data: {
          'errors': {
            'email': ['is invalid']
          }
        },
      ));
      expect(f, isA<ValidationFailure>());
      expect((f as ValidationFailure).errors['email'], ['is invalid']);
    });

    test('500 -> ServerFailure(500)', () {
      final f = ExceptionMapper.fromDio(_err(code: 500));
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).code, 500);
    });
  });
}
