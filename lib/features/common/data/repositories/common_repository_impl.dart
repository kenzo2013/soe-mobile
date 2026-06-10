import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../auth/data/mappers/user_mapper.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/account_address.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/service_contract.dart';
import '../../domain/repositories/common_repository.dart';
import '../datasources/common_remote_datasource.dart';

class CommonRepositoryImpl implements CommonRepository {
  const CommonRepositoryImpl({
    required CommonRemoteDatasource remote,
    required SecureStorage storage,
  })  : _remote = remote,
        _storage = storage;

  final CommonRemoteDatasource _remote;
  final SecureStorage _storage;

  @override
  Future<Result<User, Failure>> updateProfile(
    UpdateProfileParams params,
  ) async {
    try {
      final user = (await _remote.updateProfile(params)).toEntity();
      // Rafraîchit le cache local lu par `currentUserProvider`.
      await _storage.write(
        StorageKeys.currentUser,
        jsonEncode(_userToStorage(user)),
      );
      return Ok(user);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    try {
      await _remote.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmation: confirmation,
      );
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<AccountAddress, Failure>> getAddress() async {
    try {
      return Ok(await _remote.getAddress());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<AccountAddress, Failure>> updateAddress(
    AccountAddress address,
  ) async {
    try {
      return Ok(await _remote.updateAddress(address));
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> switchRole(String role) async {
    try {
      await _remote.switchRole(role);
      await _storage.write(StorageKeys.currentRole, role);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> addRole(String role) async {
    try {
      await _remote.addRole(role);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<NotificationPreferences, Failure>>
      getNotificationPreferences() async {
    try {
      return Ok(await _remote.getNotificationPreferences());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<NotificationPreferences, Failure>>
      updateNotificationPreferences(NotificationPreferences prefs) async {
    try {
      return Ok(await _remote.updateNotificationPreferences(prefs));
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<List<AppNotification>, Failure>> getNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      return Ok(await _remote.getNotifications(unreadOnly: unreadOnly));
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> markNotificationRead(String id) async {
    try {
      await _remote.markNotificationRead(id);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> markAllNotificationsRead() async {
    try {
      await _remote.markAllNotificationsRead();
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> deleteNotification(String id) async {
    try {
      await _remote.deleteNotification(id);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<List<ServiceContract>, Failure>> getContracts() async {
    try {
      return Ok(await _remote.getContracts());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> signContract(String id, File signature) async {
    try {
      await _remote.signContract(id, signature);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }

  @override
  Future<Result<void, Failure>> signAmendment(
    String contractId,
    String amendmentId,
    File signature,
  ) async {
    try {
      await _remote.signAmendment(contractId, amendmentId, signature);
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure());
    }
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
        'multi_role': u.multiRole,
      };
}
