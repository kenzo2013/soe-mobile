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
  Future<Result<AuthSession, Failure>> register({
    required RegisterParams params,
  }) async {
    try {
      final dto = await _remote.register(params);
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
  }
}
