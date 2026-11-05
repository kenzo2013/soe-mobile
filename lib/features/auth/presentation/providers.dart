import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/storage/storage_keys.dart';
import '../data/datasources/auth_v2_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/auth_session.dart';
import '../domain/entities/user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/logout.dart';

final authV2DatasourceProvider = Provider<AuthV2Datasource>(
  (ref) => AuthV2Datasource(ref.watch(dioV2Provider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authV2DatasourceProvider),
    storage: ref.watch(secureStorageProvider),
  ),
);

final logoutUsecaseProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

/// Once signed in (sign-in, e-mail code, password reset): the global providers follow, so
/// the router guard and the API clients see the new session.
void syncSession(Ref ref, AuthSession session) {
  ref.read(authTokenProvider.notifier).state = session.accessToken;
  ref.read(currentRoleProvider.notifier).state = session.user.role.apiValue;
  ref.read(secureStorageProvider)
    ..write(StorageKeys.authToken, session.accessToken)
    ..write(StorageKeys.currentRole, session.user.role.apiValue);
}
