import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/entities/auth_session.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/domain/usecases/login.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late Login usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = Login(repo);
  });

  AuthSession session() => const AuthSession(
        user: User(
          id: '1',
          email: 'a@b.com',
          firstName: 'Jean',
          lastName: 'Dupont',
          role: UserRole.parent,
        ),
        accessToken: 'token-xyz',
      );

  test('returns ValidationFailure when email is invalid', () async {
    final r = await usecase(email: 'invalid', password: 'secret');
    expect(r, isA<Err<AuthSession, Failure>>());
    final f = (r as Err<AuthSession, Failure>).failure;
    expect(f, isA<ValidationFailure>());
    expect((f as ValidationFailure).errors.containsKey('email'), isTrue);
  });

  test('returns ValidationFailure when password is empty', () async {
    final r = await usecase(email: 'a@b.com', password: '');
    final f = (r as Err<AuthSession, Failure>).failure;
    expect(f, isA<ValidationFailure>());
    expect((f as ValidationFailure).errors.containsKey('password'), isTrue);
  });

  test('returns Ok when repo succeeds', () async {
    when(() => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Ok(session()));

    final r = await usecase(email: 'a@b.com', password: 'secret123');
    expect(r, isA<Ok<AuthSession, Failure>>());
  });

  test('propagates UnauthorizedFailure from repo', () async {
    when(() => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Err(UnauthorizedFailure()));

    final r = await usecase(email: 'a@b.com', password: 'wrong123');
    expect(
      (r as Err<AuthSession, Failure>).failure,
      isA<UnauthorizedFailure>(),
    );
  });

  test('propagates NetworkFailure from repo', () async {
    when(() => repo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Err(NetworkFailure()));

    final r = await usecase(email: 'a@b.com', password: 'secret123');
    expect(
      (r as Err<AuthSession, Failure>).failure,
      isA<NetworkFailure>(),
    );
  });
}
