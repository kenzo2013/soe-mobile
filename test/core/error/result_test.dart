import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';

void main() {
  group('Result', () {
    test('Ok exposes value', () {
      const r = Ok<int, Failure>(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.valueOrNull, 42);
      expect(r.failureOrNull, isNull);
    });

    test('Err exposes failure', () {
      const r = Err<int, Failure>(NetworkFailure());
      expect(r.isOk, isFalse);
      expect(r.isErr, isTrue);
      expect(r.valueOrNull, isNull);
      expect(r.failureOrNull, isA<NetworkFailure>());
    });

    test('equality works', () {
      const a = Ok<int, Failure>(1);
      const b = Ok<int, Failure>(1);
      const c = Ok<int, Failure>(2);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));

      const e1 = Err<int, Failure>(NetworkFailure());
      const e2 = Err<int, Failure>(NetworkFailure());
      expect(e1, equals(e2));
    });

    test('switch pattern matches both branches', () {
      const Result<int, Failure> ok = Ok(1);
      final v1 = switch (ok) { Ok(:final value) => value, Err() => -1 };
      expect(v1, 1);

      const Result<int, Failure> err = Err(UnknownFailure());
      final v2 = switch (err) { Ok(:final value) => value, Err() => -1 };
      expect(v2, -1);
    });
  });
}
