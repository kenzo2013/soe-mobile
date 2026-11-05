import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';
import 'package:soe/features/auth/data/datasources/auth_v2_datasource.dart';
import 'package:soe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soe/features/auth/domain/entities/auth_flow.dart';
import 'package:soe/features/auth/domain/entities/user.dart';

class _Remote extends Mock implements AuthV2Datasource {}

class _Storage extends Mock implements SecureStorage {}

const _user = {
  'id': 7,
  'first_name': 'Awa',
  'last_name': 'Ngono',
  'email': 'awa@example.com',
  'phone': '+237 699000333',
  'lang': 'fr',
  'roles': ['parent', 'tutor'],
  'current_role': 'parent',
  'confirmed': true,
  'created_at': '2026-11-04T10:00:00+01:00',
};

DioException _error(int status, String code) => DioException(
      requestOptions: RequestOptions(path: '/auth'),
      response: Response(
        requestOptions: RequestOptions(path: '/auth'),
        statusCode: status,
        data: {
          'errors': [
            {'code': code, 'message': 'msg'},
          ],
        },
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  late _Remote remote;
  late _Storage storage;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _Remote();
    storage = _Storage();
    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
    repository = AuthRepositoryImpl(remote: remote, storage: storage);
  });

  test('sign-in stores the token and the account, with every role', () async {
    when(() => remote.signIn('awa@example.com', 'pw')).thenAnswer(
      (_) async => (
        status: 201,
        data: {'token': 'jwt', 'token_expires_at': 'x', 'user': _user}
      ),
    );

    final result =
        await repository.signIn(login: 'awa@example.com', password: 'pw');

    final outcome = result.valueOrNull! as SignedIn;
    expect(outcome.session.accessToken, 'jwt');
    expect(outcome.session.user.role, UserRole.parent);
    expect(outcome.session.user.multiRole, isTrue);
    verify(() => storage.write(StorageKeys.authToken, 'jwt')).called(1);
    verify(() => storage.write(StorageKeys.currentRole, 'parent')).called(1);
  });

  test('an unverified account gives a pending check and stores nothing',
      () async {
    when(() => remote.signIn(any(), any())).thenAnswer(
      (_) async => (
        status: 202,
        data: {
          'pending_token': 'p',
          'email': 'a•••••@example.com',
          'resend_in': 60
        }
      ),
    );

    final result = await repository.signIn(login: 'a', password: 'b');

    final outcome = result.valueOrNull! as ConfirmationRequired;
    expect(outcome.pending.pendingToken, 'p');
    expect(outcome.pending.resendIn, 60);
    verifyNever(() => storage.write(StorageKeys.authToken, any()));
  });

  test('the v2 error codes become typed failures', () async {
    when(() => remote.signIn(any(), any()))
        .thenThrow(_error(401, 'invalid_credentials'));
    when(() => remote.confirmEmail(any(), any()))
        .thenThrow(_error(422, 'code_expired'));
    when(() => remote.verifyResetCode(any(), any()))
        .thenThrow(_error(410, 'link_expired'));

    expect((await repository.signIn(login: 'a', password: 'b')).failureOrNull,
        isA<InvalidCredentialsFailure>());
    final code =
        (await repository.confirmEmail(pendingToken: 'p', code: '000000'))
            .failureOrNull;
    expect(
        code,
        isA<CodeFailure>()
            .having((f) => f.problem, 'problem', CodeProblem.expired));
    expect(
      (await repository.verifyResetCode(resetToken: 'r', code: '000000'))
          .failureOrNull,
      isA<LinkExpiredFailure>(),
    );
  });

  test(
      'signing out clears the local session even when the server cannot be reached',
      () async {
    when(() => remote.signOut()).thenThrow(_error(500, 'server_error'));

    final result = await repository.logout();

    expect(result, isA<Ok<void, Failure>>());
    verify(() => storage.delete(StorageKeys.authToken)).called(1);
    verify(() => storage.delete(StorageKeys.currentUser)).called(1);
  });
}
