import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/network/api_endpoints.dart';
import 'package:soe/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:soe/features/auth/data/mappers/user_mapper.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late AuthRemoteDatasource ds;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    dio = _MockDio();
    ds = AuthRemoteDatasource(dio);
  });

  Map<String, dynamic> userBody() => {
        'data': {
          'id': '31',
          'type': 'user',
          'attributes': {
            'email': 'jean@soe.cm',
            'first_name': 'Jean',
            'last_name': 'Dupont',
            'role': 'tutor',
          },
        },
      };

  Response<Map<String, dynamic>> okResponse(
    Map<String, dynamic> data, {
    Map<String, List<String>>? headers,
    int status = 200,
  }) =>
      Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ''),
        statusCode: status,
        data: data,
        headers: headers == null ? null : Headers.fromMap(headers),
      );

  group('login', () {
    test('appelle POST /users/login avec user{email,password}', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse(
            userBody(),
            headers: {
              'authorization': ['Bearer jwt-xyz'],
            },
          ));

      final dto = await ds.login(email: 'jean@soe.cm', password: 'secret');

      expect(dto.accessToken, 'jwt-xyz');
      expect(dto.data.toEntity().email, 'jean@soe.cm');

      final captured = verify(() => dio.post<Map<String, dynamic>>(
            captureAny(),
            data: captureAny(named: 'data'),
          )).captured;
      expect(captured[0], ApiEndpoints.login);
      expect(captured[1], {
        'user': {'email': 'jean@soe.cm', 'password': 'secret'},
      });
    });

    test('strip le préfixe Bearer (insensible à la casse de la clé)', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse(
            userBody(),
            headers: {
              'Authorization': ['Bearer plain-token'],
            },
          ));

      final dto = await ds.login(email: 'a@b.cm', password: 'p');
      expect(dto.accessToken, 'plain-token');
    });

    test('garde le token brut si pas de préfixe Bearer', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse(
            userBody(),
            headers: {
              'authorization': ['raw-token'],
            },
          ));

      final dto = await ds.login(email: 'a@b.cm', password: 'p');
      expect(dto.accessToken, 'raw-token');
    });

    test('lève DioException si header Authorization absent', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse(userBody()));

      expect(
        () => ds.login(email: 'a@b.cm', password: 'p'),
        throwsA(isA<DioException>()),
      );
    });

    test('propage la DioException réseau du Dio', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      ));

      expect(
        () => ds.login(email: 'a@b.cm', password: 'bad'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('register', () {
    test('POST /users/register avec client_type mobile et user complet',
        () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse({'data': userBody()['data']}));

      final dto = await ds.register(const RegisterParams(
        email: 'jean@soe.cm',
        password: 'secret123',
        passwordConfirmation: 'secret123',
        firstName: 'Jean',
        lastName: 'Dupont',
        role: UserRole.tutor,
        acceptCgu: true,
        city: 'Douala',
      ));

      expect(dto.data.toEntity().email, 'jean@soe.cm');

      final captured = verify(() => dio.post<Map<String, dynamic>>(
            captureAny(),
            data: captureAny(named: 'data'),
          )).captured;
      expect(captured[0], ApiEndpoints.register);
      final body = captured[1] as Map<String, dynamic>;
      expect(body['client_type'], 'mobile');
      final user = body['user'] as Map<String, dynamic>;
      expect(user['email'], 'jean@soe.cm');
      expect(user['role'], 'tutor');
      expect(user['accept_cgu'], true);
      expect(user['lang'], 'fr');
      // city présent => address_attributes inclus
      expect((user['address_attributes'] as Map)['city'], 'Douala');
    });

    test('omet address_attributes quand aucun champ adresse', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse({'data': userBody()['data']}));

      await ds.register(const RegisterParams(
        email: 'jean@soe.cm',
        password: 'secret123',
        passwordConfirmation: 'secret123',
        firstName: 'Jean',
        lastName: 'Dupont',
        role: UserRole.parent,
        acceptCgu: true,
      ));

      final captured = verify(() => dio.post<Map<String, dynamic>>(
            captureAny(),
            data: captureAny(named: 'data'),
          )).captured;
      final user = (captured[1] as Map)['user'] as Map;
      expect(user.containsKey('address_attributes'), isFalse);
      expect(user.containsKey('civility'), isFalse);
      expect(user.containsKey('phone'), isFalse);
    });
  });

  group('verifyConfirmationCode', () {
    test('POST verify_code avec email+code et parse data', () async {
      when(() => dio.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => okResponse({'data': userBody()['data']}));

      final dto =
          await ds.verifyConfirmationCode(email: 'jean@soe.cm', code: '1234');
      expect(dto.data.toEntity().id, '31');

      final captured = verify(() => dio.post<Map<String, dynamic>>(
            captureAny(),
            data: captureAny(named: 'data'),
          )).captured;
      expect(captured[0], ApiEndpoints.confirmationVerifyCode);
      expect(captured[1], {'email': 'jean@soe.cm', 'code': '1234'});
    });
  });

  group('resendConfirmation', () {
    test('POST /users/confirmation avec email + client_type', () async {
      when(() => dio.post<void>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response<void>(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      await ds.resendConfirmation(email: 'jean@soe.cm');

      final captured = verify(
        () => dio.post<void>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured[0], ApiEndpoints.confirmation);
      expect(captured[1], {'email': 'jean@soe.cm', 'client_type': 'mobile'});
    });
  });

  group('requestPasswordReset', () {
    test('POST /users/password avec email + client_type', () async {
      when(() => dio.post<void>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response<void>(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      await ds.requestPasswordReset(email: 'jean@soe.cm');

      final captured = verify(
        () => dio.post<void>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured[0], ApiEndpoints.passwordReset);
      expect(captured[1], {'email': 'jean@soe.cm', 'client_type': 'mobile'});
    });
  });

  group('verifyResetCode', () {
    test('POST verify_code avec email + code', () async {
      when(() => dio.post<void>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response<void>(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      await ds.verifyResetCode(email: 'jean@soe.cm', code: '9999');

      final captured = verify(
        () => dio.post<void>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured[0], ApiEndpoints.passwordVerifyCode);
      expect(captured[1], {'email': 'jean@soe.cm', 'code': '9999'});
    });
  });

  group('resetPasswordWithCode', () {
    test('PATCH reset_with_code avec tous les champs', () async {
      when(() => dio.patch<void>(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response<void>(
                requestOptions: RequestOptions(path: ''),
                statusCode: 200,
              ));

      await ds.resetPasswordWithCode(
        email: 'jean@soe.cm',
        code: '4321',
        password: 'new-pass',
        passwordConfirmation: 'new-pass',
      );

      final captured = verify(
        () => dio.patch<void>(captureAny(), data: captureAny(named: 'data')),
      ).captured;
      expect(captured[0], ApiEndpoints.passwordResetWithCode);
      expect(captured[1], {
        'email': 'jean@soe.cm',
        'code': '4321',
        'password': 'new-pass',
        'password_confirmation': 'new-pass',
      });
    });
  });

  group('logout', () {
    test('DELETE /users/logout', () async {
      when(() => dio.delete<void>(any())).thenAnswer((_) async =>
          Response<void>(
              requestOptions: RequestOptions(path: ''), statusCode: 204));

      await ds.logout();

      final captured = verify(() => dio.delete<void>(captureAny())).captured;
      expect(captured[0], ApiEndpoints.logout);
    });
  });

  group('getCurrentUser', () {
    test('GET /current_user avec enveloppe data', () async {
      when(() => dio.get<Map<String, dynamic>>(any()))
          .thenAnswer((_) async => okResponse(userBody()));

      final dto = await ds.getCurrentUser();
      expect(dto.toEntity().email, 'jean@soe.cm');

      final captured =
          verify(() => dio.get<Map<String, dynamic>>(captureAny())).captured;
      expect(captured[0], ApiEndpoints.currentUser);
    });

    test('GET /current_user accepte un body sans enveloppe data', () async {
      when(() => dio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => okResponse(
          userBody()['data'] as Map<String, dynamic>,
        ),
      );

      final dto = await ds.getCurrentUser();
      expect(dto.toEntity().id, '31');
    });
  });
}
