import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/domain/usecases/reset_password.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late ResetPassword usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = ResetPassword(repo);
  });

  test('rejects invalid email', () async {
    final r = await usecase(
      email: 'not-an-email',
      code: '123456',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    );
    final f = (r as Err<void, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('email'), isTrue);
  });

  test('rejects code !=6 digits', () async {
    final r = await usecase(
      email: 'user@soe.com',
      code: '123',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    );
    final f = (r as Err<void, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('code'), isTrue);
  });

  test('rejects short password', () async {
    final r = await usecase(
      email: 'user@soe.com',
      code: '123456',
      password: '12345',
      passwordConfirmation: '12345',
    );
    final f = (r as Err<void, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('password'), isTrue);
  });

  test('rejects mismatched confirmation', () async {
    final r = await usecase(
      email: 'user@soe.com',
      code: '123456',
      password: 'secret123',
      passwordConfirmation: 'other___',
    );
    final f = (r as Err<void, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('password_confirmation'), isTrue);
  });

  test('forwards to repo and returns Ok on success', () async {
    when(() => repo.resetPasswordWithCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        )).thenAnswer((_) async => const Ok<void, Failure>(null));

    final r = await usecase(
      email: 'user@soe.com',
      code: '123456',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    );
    expect(r, isA<Ok<void, Failure>>());
  });
}
