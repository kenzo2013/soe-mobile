import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/domain/usecases/verify_confirmation_code.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late VerifyConfirmationCode usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = VerifyConfirmationCode(repo);
  });

  test('rejects invalid email', () async {
    final r = await usecase(email: 'not-an-email', code: '123456');
    final f = (r as Err<User, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('email'), isTrue);
  });

  test('rejects code with !=6 digits', () async {
    final r = await usecase(email: 'a@b.com', code: '123');
    final f = (r as Err<User, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('code'), isTrue);
  });

  test('forwards to repo on valid input', () async {
    when(() => repo.verifyConfirmationCode(
        email: any(named: 'email'), code: any(named: 'code'))).thenAnswer(
      (_) async => const Ok<User, Failure>(
        User(
          id: '1',
          email: 'a@b.com',
          firstName: 'A',
          lastName: 'B',
          role: UserRole.parent,
        ),
      ),
    );

    final r = await usecase(email: 'a@b.com', code: '123456');
    expect(r, isA<Ok<User, Failure>>());
  });
}
