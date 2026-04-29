import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/domain/usecases/request_password_reset.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late RequestPasswordReset usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = RequestPasswordReset(repo);
  });

  test('rejects invalid email locally', () async {
    final r = await usecase(email: 'no-at');
    expect(
      (r as Err<void, Failure>).failure,
      isA<ValidationFailure>(),
    );
    verifyNever(() => repo.requestPasswordReset(email: any(named: 'email')));
  });

  test('forwards to repo when email valid', () async {
    when(() => repo.requestPasswordReset(email: any(named: 'email')))
        .thenAnswer((_) async => const Ok(null));

    final r = await usecase(email: 'a@b.com');
    expect(r, isA<Ok<void, Failure>>());
  });

  test('propagates network failure', () async {
    when(() => repo.requestPasswordReset(email: any(named: 'email')))
        .thenAnswer((_) async => const Err(NetworkFailure()));

    final r = await usecase(email: 'a@b.com');
    expect(
      (r as Err<void, Failure>).failure,
      isA<NetworkFailure>(),
    );
  });
}
