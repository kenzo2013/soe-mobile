import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/domain/usecases/verify_reset_code.dart';

class _MockRepo extends Mock implements AuthRepository {}

void main() {
  late _MockRepo repo;
  late VerifyResetCode usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = VerifyResetCode(repo);
  });

  test('rejects bad email + bad code together', () async {
    final r = await usecase(email: 'x', code: '12');
    final f = (r as Err<void, Failure>).failure as ValidationFailure;
    expect(f.errors.containsKey('email'), isTrue);
    expect(f.errors.containsKey('code'), isTrue);
  });

  test('forwards on valid input', () async {
    when(() => repo.verifyResetCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        )).thenAnswer((_) async => const Ok<void, Failure>(null));

    final r = await usecase(email: 'a@b.com', code: '123456');
    expect(r, isA<Ok<void, Failure>>());
  });
}
