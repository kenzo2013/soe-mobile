import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/entities/auth_session.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
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

  test('rejects empty token', () async {
    final r = await usecase(
      token: '',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    );
    final f = (r as Err<AuthSession, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('reset_password_token'), isTrue);
  });

  test('rejects short password', () async {
    final r = await usecase(
      token: 'tok',
      password: '12345',
      passwordConfirmation: '12345',
    );
    final f = (r as Err<AuthSession, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('password'), isTrue);
  });

  test('rejects mismatched confirmation', () async {
    final r = await usecase(
      token: 'tok',
      password: 'secret123',
      passwordConfirmation: 'other___',
    );
    final f = (r as Err<AuthSession, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('password_confirmation'), isTrue);
  });

  test('forwards to repo and returns Ok on success', () async {
    when(() => repo.resetPassword(
          token: any(named: 'token'),
          password: any(named: 'password'),
          passwordConfirmation: any(named: 'passwordConfirmation'),
        )).thenAnswer(
      (_) async => const Ok(
        AuthSession(
          user: User(
            id: '1',
            email: 'a@b.com',
            firstName: 'Jean',
            lastName: 'Dupont',
            role: UserRole.parent,
          ),
          accessToken: 'tok',
        ),
      ),
    );

    final r = await usecase(
      token: 'tok',
      password: 'secret123',
      passwordConfirmation: 'secret123',
    );
    expect(r, isA<Ok<AuthSession, Failure>>());
  });
}
