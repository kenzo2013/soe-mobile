import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDatasource remote,
    required SecureStorage storage,
  })  : _remote = remote,
        _storage = storage;

  final AuthRemoteDatasource _remote;
  final SecureStorage _storage;

  @override
  Future<Result<AuthSession, Failure>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.login(email: email, password: password);
      final session = AuthSession(
        user: dto.data.toEntity(),
        accessToken: dto.accessToken,
      );
      await _persist(session);
      return Ok(session);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<User, Failure>> register({
    required RegisterParams params,
  }) async {
    try {
      final dto = await _remote.register(params);
      return Ok(dto.data.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> resendConfirmationCode({
    required String email,
  }) async {
    try {
      await _remote.resendConfirmation(email: email);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<User, Failure>> verifyConfirmationCode({
    required String email,
    required String code,
  }) async {
    try {
      final dto = await _remote.verifyConfirmationCode(email: email, code: code);
      return Ok(dto.data.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> requestPasswordReset({
    required String email,
  }) async {
    try {
      await _remote.requestPasswordReset(email: email);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    try {
      await _remote.verifyResetCode(email: email, code: code);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _remote.resetPasswordWithCode(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<User, Failure>> fetchCurrentUser() async {
    try {
      final dto = await _remote.getCurrentUser();
      final user = dto.toEntity();
      await _storage.write(StorageKeys.currentRole, user.role.apiValue);
      await _storage.write(
        StorageKeys.currentUser,
        jsonEncode(_userToStorage(user)),
      );
      return Ok(user);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _remote.logout();
    } on DioException catch (_) {
      // On efface localement même si le serveur échoue.
    } catch (_) {}
    await _storage.delete(StorageKeys.authToken);
    await _storage.delete(StorageKeys.currentUser);
    await _storage.delete(StorageKeys.currentRole);
    return const Ok(null);
  }

  Future<void> _persist(AuthSession s) async {
    await _storage.write(StorageKeys.authToken, s.accessToken);
    await _storage.write(StorageKeys.currentRole, s.user.role.apiValue);
    await _storage.write(
      StorageKeys.currentUser,
      jsonEncode(_userToStorage(s.user)),
    );
  }

  Map<String, dynamic> _userToStorage(User u) => {
        'id': u.id,
        'email': u.email,
        'first_name': u.firstName,
        'last_name': u.lastName,
        'role': u.role.apiValue,
        if (u.civility != null) 'civility': u.civility,
        if (u.phone != null) 'phone': u.phone,
        if (u.lang != null) 'lang': u.lang,
        if (u.photoUrl != null) 'photo_url': u.photoUrl,
      };
}
