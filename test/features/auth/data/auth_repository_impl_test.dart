import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';
import 'package:soe/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:soe/features/auth/data/dtos/auth_response_dto.dart';
import 'package:soe/features/auth/data/dtos/user_dto.dart';
import 'package:soe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soe/features/auth/domain/entities/auth_session.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';

class _MockDs extends Mock implements AuthRemoteDatasource {}

class _MockStorage extends Mock implements SecureStorage {}

void main() {
  late _MockDs remote;
  late _MockStorage storage;
  late AuthRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(const RegisterParams(
      email: 'x@y.cm',
      password: 'p',
      passwordConfirmation: 'p',
      firstName: 'A',
      lastName: 'B',
      role: UserRole.parent,
      acceptCgu: true,
    ));
  });

  setUp(() {
    remote = _MockDs();
    storage = _MockStorage();
    repo = AuthRepositoryImpl(remote: remote, storage: storage);

    when(() => storage.write(any(), any())).thenAnswer((_) async {});
    when(() => storage.delete(any())).thenAnswer((_) async {});
  });

  UserDto userDto({String role = 'tutor'}) => UserDto.fromJson({
        'id': '31',
        'type': 'user',
        'attributes': {
          'email': 'jean@soe.cm',
          'first_name': 'Jean',
          'last_name': 'Dupont',
          'role': role,
        },
      });

  DioException dioErr(int status) => DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: status,
          requestOptions: RequestOptions(path: ''),
        ),
      );

  group('login', () {
    test('Ok + persiste token/role/user', () async {
      when(() => remote.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) async =>
              LoginResponseDto(data: userDto(), accessToken: 'jwt-xyz'));

      final r = await repo.login(email: 'jean@soe.cm', password: 'secret');

      expect(r, isA<Ok<AuthSession, Failure>>());
      final session = (r as Ok<AuthSession, Failure>).value;
      expect(session.accessToken, 'jwt-xyz');
      expect(session.user.email, 'jean@soe.cm');

      verify(() => storage.write(StorageKeys.authToken, 'jwt-xyz')).called(1);
      verify(() => storage.write(StorageKeys.currentRole, 'tutor')).called(1);
      verify(() => storage.write(StorageKeys.currentUser, any())).called(1);
    });

    test('mappe DioException 401 vers UnauthorizedFailure', () async {
      when(() => remote.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(dioErr(401));

      final r = await repo.login(email: 'jean@soe.cm', password: 'bad');
      expect(
          (r as Err<AuthSession, Failure>).failure, isA<UnauthorizedFailure>());
      verifyNever(() => storage.write(any(), any()));
    });

    test('mappe 412 vers EmailNotConfirmedFailure', () async {
      when(() => remote.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(dioErr(412));

      final r = await repo.login(email: 'jean@soe.cm', password: 'secret');
      expect((r as Err<AuthSession, Failure>).failure,
          isA<EmailNotConfirmedFailure>());
    });

    test('exception non-Dio => UnknownFailure', () async {
      when(() => remote.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('boom'));

      final r = await repo.login(email: 'jean@soe.cm', password: 'secret');
      expect((r as Err<AuthSession, Failure>).failure, isA<UnknownFailure>());
    });
  });

  group('register', () {
    test('Ok renvoie le user mappé', () async {
      when(() => remote.register(any()))
          .thenAnswer((_) async => RegisterResponseDto(data: userDto()));

      final r = await repo.register(
        params: const RegisterParams(
          email: 'jean@soe.cm',
          password: 'secret123',
          passwordConfirmation: 'secret123',
          firstName: 'Jean',
          lastName: 'Dupont',
          role: UserRole.tutor,
          acceptCgu: true,
        ),
      );

      expect((r as Ok<User, Failure>).value.email, 'jean@soe.cm');
    });

    test('mappe 422 vers ValidationFailure', () async {
      when(() => remote.register(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 422,
          requestOptions: RequestOptions(path: ''),
          data: {
            'errors': {
              'email': ['already taken'],
            },
          },
        ),
      ));

      final r = await repo.register(
        params: const RegisterParams(
          email: 'jean@soe.cm',
          password: 'p',
          passwordConfirmation: 'p',
          firstName: 'Jean',
          lastName: 'Dupont',
          role: UserRole.tutor,
          acceptCgu: true,
        ),
      );

      final f = (r as Err<User, Failure>).failure;
      expect(f, isA<ValidationFailure>());
      expect((f as ValidationFailure).errors['email'], ['already taken']);
    });
  });

  group('resendConfirmationCode', () {
    test('Ok(null) en cas de succès', () async {
      when(() => remote.resendConfirmation(email: any(named: 'email')))
          .thenAnswer((_) async {});
      final r = await repo.resendConfirmationCode(email: 'jean@soe.cm');
      expect(r, isA<Ok<void, Failure>>());
    });

    test('mappe DioException timeout vers TimeoutFailure', () async {
      when(() => remote.resendConfirmation(email: any(named: 'email')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.receiveTimeout,
      ));
      final r = await repo.resendConfirmationCode(email: 'jean@soe.cm');
      expect((r as Err<void, Failure>).failure, isA<TimeoutFailure>());
    });
  });

  group('verifyConfirmationCode', () {
    test('Ok renvoie le user', () async {
      when(() => remote.verifyConfirmationCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          )).thenAnswer((_) async => ConfirmationResponseDto(data: userDto()));

      final r =
          await repo.verifyConfirmationCode(email: 'jean@soe.cm', code: '1234');
      expect((r as Ok<User, Failure>).value.id, '31');
    });

    test('mappe DioException connectionError vers NetworkFailure', () async {
      when(() => remote.verifyConfirmationCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));
      final r =
          await repo.verifyConfirmationCode(email: 'jean@soe.cm', code: 'x');
      expect((r as Err<User, Failure>).failure, isA<NetworkFailure>());
    });
  });

  group('requestPasswordReset / verifyResetCode / resetPasswordWithCode', () {
    test('requestPasswordReset Ok', () async {
      when(() => remote.requestPasswordReset(email: any(named: 'email')))
          .thenAnswer((_) async {});
      expect(await repo.requestPasswordReset(email: 'jean@soe.cm'),
          isA<Ok<void, Failure>>());
    });

    test('verifyResetCode Ok', () async {
      when(() => remote.verifyResetCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          )).thenAnswer((_) async {});
      expect(await repo.verifyResetCode(email: 'jean@soe.cm', code: '1'),
          isA<Ok<void, Failure>>());
    });

    test('resetPasswordWithCode Ok', () async {
      when(() => remote.resetPasswordWithCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
            password: any(named: 'password'),
            passwordConfirmation: any(named: 'passwordConfirmation'),
          )).thenAnswer((_) async {});
      final r = await repo.resetPasswordWithCode(
        email: 'jean@soe.cm',
        code: '1',
        password: 'p',
        passwordConfirmation: 'p',
      );
      expect(r, isA<Ok<void, Failure>>());
    });

    test('resetPasswordWithCode mappe 404 vers NotFoundFailure', () async {
      when(() => remote.resetPasswordWithCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
            password: any(named: 'password'),
            passwordConfirmation: any(named: 'passwordConfirmation'),
          )).thenThrow(dioErr(404));
      final r = await repo.resetPasswordWithCode(
        email: 'jean@soe.cm',
        code: '1',
        password: 'p',
        passwordConfirmation: 'p',
      );
      expect((r as Err<void, Failure>).failure, isA<NotFoundFailure>());
    });
  });

  group('fetchCurrentUser', () {
    test('Ok + persiste role et user', () async {
      when(() => remote.getCurrentUser()).thenAnswer((_) async => userDto());

      final r = await repo.fetchCurrentUser();
      expect((r as Ok<User, Failure>).value.email, 'jean@soe.cm');
      verify(() => storage.write(StorageKeys.currentRole, 'tutor')).called(1);
      verify(() => storage.write(StorageKeys.currentUser, any())).called(1);
    });

    test('mappe DioException 403 vers ForbiddenFailure', () async {
      when(() => remote.getCurrentUser()).thenThrow(dioErr(403));
      final r = await repo.fetchCurrentUser();
      expect((r as Err<User, Failure>).failure, isA<ForbiddenFailure>());
    });
  });

  group('logout', () {
    test('efface le storage et renvoie Ok même si le serveur réussit',
        () async {
      when(() => remote.logout()).thenAnswer((_) async {});

      final r = await repo.logout();
      expect(r, isA<Ok<void, Failure>>());
      verify(() => storage.delete(StorageKeys.authToken)).called(1);
      verify(() => storage.delete(StorageKeys.currentUser)).called(1);
      verify(() => storage.delete(StorageKeys.currentRole)).called(1);
    });

    test('efface le storage même si le datasource lève DioException', () async {
      when(() => remote.logout()).thenThrow(dioErr(500));

      final r = await repo.logout();
      expect(r, isA<Ok<void, Failure>>());
      verify(() => storage.delete(StorageKeys.authToken)).called(1);
    });

    test('efface le storage même si une exception non-Dio est levée', () async {
      when(() => remote.logout()).thenThrow(Exception('boom'));

      final r = await repo.logout();
      expect(r, isA<Ok<void, Failure>>());
      verify(() => storage.delete(StorageKeys.currentRole)).called(1);
    });
  });
}
