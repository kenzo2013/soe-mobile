import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/storage/storage_keys.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login.dart';
import '../domain/usecases/logout.dart';
import '../domain/usecases/register.dart';
import '../domain/usecases/request_password_reset.dart';
import '../domain/usecases/resend_confirmation.dart';
import '../domain/usecases/reset_password.dart';
import '../domain/usecases/verify_confirmation_code.dart';
import '../domain/usecases/verify_reset_code.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDatasourceProvider),
    storage: ref.watch(secureStorageProvider),
  ),
);

final loginUsecaseProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final registerUsecaseProvider = Provider<Register>(
  (ref) => Register(ref.watch(authRepositoryProvider)),
);

final resendConfirmationUsecaseProvider = Provider<ResendConfirmation>(
  (ref) => ResendConfirmation(ref.watch(authRepositoryProvider)),
);

final verifyConfirmationCodeUsecaseProvider = Provider<VerifyConfirmationCode>(
  (ref) => VerifyConfirmationCode(ref.watch(authRepositoryProvider)),
);

final requestPasswordResetUsecaseProvider = Provider<RequestPasswordReset>(
  (ref) => RequestPasswordReset(ref.watch(authRepositoryProvider)),
);

final verifyResetCodeUsecaseProvider = Provider<VerifyResetCode>(
  (ref) => VerifyResetCode(ref.watch(authRepositoryProvider)),
);

final logoutUsecaseProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

final resetPasswordUsecaseProvider = Provider<ResetPassword>(
  (ref) => ResetPassword(ref.watch(authRepositoryProvider)),
);

/// Side-effect : après login/register réussis, sync les providers globaux.
void syncAuthState(Ref ref, String token, String role) {
  ref.read(authTokenProvider.notifier).state = token;
  ref.read(currentRoleProvider.notifier).state = role;
  ref.read(secureStorageProvider).write(StorageKeys.authToken, token);
  ref.read(secureStorageProvider).write(StorageKeys.currentRole, role);
}
