import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';

// Branches non couvertes par test/core/error/result_test.dart :
// hashCode, identité, inégalités croisées Ok/Err, valeurs nullables.
void main() {
  group('Result · hashCode', () {
    test('Ok.hashCode = value.hashCode', () {
      const r = Ok<int, Failure>(42);
      expect(r.hashCode, 42.hashCode);
    });

    test('Err.hashCode = failure.hashCode', () {
      const f = NetworkFailure();
      const r = Err<int, Failure>(f);
      expect(r.hashCode, f.hashCode);
    });

    test('deux Ok égaux partagent le même hashCode', () {
      const a = Ok<String, Failure>('x');
      const b = Ok<String, Failure>('x');
      expect(a.hashCode, b.hashCode);
    });
  });

  group('Result · égalité (branches restantes)', () {
    test('identical(this, other) → true (même instance)', () {
      const r = Ok<int, Failure>(1);
      expect(r == r, isTrue);
    });

    test('Ok != Err même quand peuplés', () {
      const Result<int, Failure> ok = Ok(1);
      const Result<int, Failure> err = Err(NetworkFailure());
      expect(ok == err, isFalse);
      expect(err == ok, isFalse);
    });

    test('Ok != objet d\'un autre type', () {
      const r = Ok<int, Failure>(1);
      // ignore: unrelated_type_equality_checks
      expect(r == 1, isFalse);
    });

    test('Err inégaux si failures différents', () {
      const a = Err<int, Failure>(NetworkFailure());
      const b = Err<int, Failure>(UnknownFailure());
      expect(a == b, isFalse);
    });
  });

  group('Result · accesseurs avec valeurs nullables', () {
    test('Ok(null) → valueOrNull null mais isOk true', () {
      const r = Ok<int?, Failure>(null);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.valueOrNull, isNull);
      expect(r.failureOrNull, isNull);
    });

    test('valueOrNull renvoie la valeur falsy (0) sans la confondre avec null',
        () {
      const r = Ok<int, Failure>(0);
      expect(r.valueOrNull, 0);
    });
  });
}
