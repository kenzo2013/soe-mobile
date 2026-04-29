import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/domain/usecases/register.dart';

class _MockRepo extends Mock implements AuthRepository {}

class _FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRegisterParams());
  });

  late _MockRepo repo;
  late Register usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = Register(repo);
  });

  RegisterParams valid() => const RegisterParams(
        email: 'a@b.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
        firstName: 'Jean',
        lastName: 'Dupont',
        role: UserRole.parent,
        acceptCgu: true,
      );

  test('returns ValidationFailure when email invalid', () async {
    final r = await usecase(
      params: const RegisterParams(
        email: 'invalid',
        password: 'secret123',
        passwordConfirmation: 'secret123',
        firstName: 'Jean',
        lastName: 'Dupont',
        role: UserRole.parent,
        acceptCgu: true,
      ),
    );
    final f = (r as Err<User, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('email'), isTrue);
  });

  test('returns ValidationFailure when passwords differ', () async {
    final r = await usecase(
      params: const RegisterParams(
        email: 'a@b.com',
        password: 'secret123',
        passwordConfirmation: 'mismatch1',
        firstName: 'Jean',
        lastName: 'Dupont',
        role: UserRole.parent,
        acceptCgu: true,
      ),
    );
    final f = (r as Err<User, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('password_confirmation'), isTrue);
  });

  test('returns ValidationFailure when CGU not accepted', () async {
    final r = await usecase(
      params: const RegisterParams(
        email: 'a@b.com',
        password: 'secret123',
        passwordConfirmation: 'secret123',
        firstName: 'Jean',
        lastName: 'Dupont',
        role: UserRole.parent,
        acceptCgu: false,
      ),
    );
    final f = (r as Err<User, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('accept_cgu'), isTrue);
  });

  test('returns Ok with User when repo succeeds', () async {
    when(() => repo.register(params: any(named: 'params'))).thenAnswer(
      (_) async => const Ok(
        User(
          id: '1',
          email: 'a@b.com',
          firstName: 'Jean',
          lastName: 'Dupont',
          role: UserRole.parent,
        ),
      ),
    );

    final r = await usecase(params: valid());
    expect(r, isA<Ok<User, Failure>>());
  });

  test('propagates ConflictFailure (email already used)', () async {
    when(() => repo.register(params: any(named: 'params'))).thenAnswer(
      (_) async => const Err<User, Failure>(ConflictFailure('Email taken')),
    );

    final r = await usecase(params: valid());
    expect(
      (r as Err<User, Failure>).failure,
      isA<ConflictFailure>(),
    );
  });
}
