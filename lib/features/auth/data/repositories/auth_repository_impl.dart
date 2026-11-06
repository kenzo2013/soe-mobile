import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/auth_flow.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/sign_up_answers.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_v2_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthV2Datasource remote,
    required SecureStorage storage,
  })  : _remote = remote,
        _storage = storage;

  final AuthV2Datasource _remote;
  final SecureStorage _storage;

  @override
  Future<Result<SignInOutcome, Failure>> signIn(
          {required String login, required String password}) =>
      _guard(() async {
        final response = await _remote.signIn(login, password);
        if (response.status == 202)
          return ConfirmationRequired(_pending(response.data));
        return SignedIn(await _store(response.data));
      });

  @override
  Future<Result<void, Failure>> validateSignUpStep(
          {required SignUpStep step, required SignUpAnswers answers}) =>
      _guard(() => _remote.validateSignUpStep(step, answers));

  @override
  Future<Result<PendingConfirmation, Failure>> signUp(SignUpAnswers answers) =>
      _guard(() async => _pending(await _remote.signUp(answers)));

  @override
  Future<Result<AuthSession, Failure>> confirmEmail(
          {required String pendingToken, required String code}) =>
      _guard(
          () async => _store(await _remote.confirmEmail(pendingToken, code)));

  @override
  Future<Result<PendingConfirmation, Failure>> resendConfirmation(
          String pendingToken) =>
      _guard(
          () async => _pending(await _remote.resendConfirmation(pendingToken)));

  @override
  Future<Result<PasswordResetTicket, Failure>> requestPasswordReset(
          String login) =>
      _guard(() async => _ticket(await _remote.requestPasswordReset(login)));

  @override
  Future<Result<String, Failure>> verifyResetCode(
          {required String resetToken, required String code}) =>
      _guard(() async => (await _remote.verifyResetCode(
          resetToken, code))['verified_token'] as String);

  @override
  Future<Result<PasswordResetTicket, Failure>> resendPasswordReset(
          String resetToken) =>
      _guard(
          () async => _ticket(await _remote.resendPasswordReset(resetToken)));

  @override
  Future<Result<AuthSession, Failure>> resetPassword({
    required String verifiedToken,
    required String password,
    required String passwordConfirmation,
  }) =>
      _guard(() async => _store(await _remote.resetPassword(
          verifiedToken, password, passwordConfirmation)));

  @override
  Future<Result<void, Failure>> logout() async {
    try {
      await _remote.signOut();
    } on Object catch (_) {
      // The local session is cleared even when the server cannot be reached.
    }
    await _storage.delete(StorageKeys.authToken);
    await _storage.delete(StorageKeys.currentUser);
    await _storage.delete(StorageKeys.currentRole);
    return const Ok(null);
  }

  @override
  Future<Result<User, Failure>> fetchCurrentUser() => _guard(() async {
        final user = userFromApi(await _remote.me());
        await _storeUser(user);
        return user;
      });

  /// The v2 account (CurrentUser schema) as the app's entity.
  static User userFromApi(Map<String, dynamic> json) {
    final roles = (json['roles'] as List<dynamic>? ?? const []).cast<String>();
    return User(
      id: json['id'].toString(),
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      role: UserRoleX.fromApi(json['current_role'] as String? ?? 'parent'),
      civility: json['civility'] as String?,
      phone: json['phone'] as String?,
      lang: json['lang'] as String?,
      multiRole: roles.length > 1,
      hasPhoto: json['has_photo'] == true,
      pushExternalId: json['push_external_id'] as String?,
    );
  }

  Future<Result<T, Failure>> _guard<T>(Future<T> Function() call) async {
    try {
      return Ok(await call());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    } on Object catch (_) {
      return const Err(UnknownFailure());
    }
  }

  PendingConfirmation _pending(Map<String, dynamic> data) =>
      PendingConfirmation(
        pendingToken: data['pending_token'] as String,
        maskedEmail: data['email'] as String? ?? '',
        resendIn: data['resend_in'] as int? ?? 0,
      );

  PasswordResetTicket _ticket(Map<String, dynamic> data) => PasswordResetTicket(
        resetToken: data['reset_token'] as String,
        resendIn: data['resend_in'] as int? ?? 0,
      );

  Future<AuthSession> _store(Map<String, dynamic> data) async {
    final session = AuthSession(
      user: userFromApi(data['user'] as Map<String, dynamic>),
      accessToken: data['token'] as String,
    );
    await _storage.write(StorageKeys.authToken, session.accessToken);
    await _storeUser(session.user);
    return session;
  }

  Future<void> _storeUser(User user) => cacheCurrentUser(_storage, user);
}

/// Keeps the signed-in account on the device (read back by `currentUserProvider`), with its
/// active role. Also used after a profile change (COM-02).
Future<void> cacheCurrentUser(SecureStorage storage, User user) async {
  await storage.write(StorageKeys.currentRole, user.role.apiValue);
  await storage.write(
    StorageKeys.currentUser,
    jsonEncode({
      'id': user.id,
      'email': user.email,
      'first_name': user.firstName,
      'last_name': user.lastName,
      'role': user.role.apiValue,
      if (user.civility != null) 'civility': user.civility,
      if (user.phone != null) 'phone': user.phone,
      if (user.lang != null) 'lang': user.lang,
      'multi_role': user.multiRole,
      'has_photo': user.hasPhoto,
      if (user.pushExternalId != null) 'push_external_id': user.pushExternalId,
    }),
  );
}
