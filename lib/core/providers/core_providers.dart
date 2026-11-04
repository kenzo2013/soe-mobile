import '../env/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../network/http_client.dart';
import '../routing/route_guards.dart';
import '../storage/preferences_storage.dart';
import '../storage/secure_storage.dart';
import '../storage/storage_keys.dart';

final loggerProvider = Provider<Logger>((ref) => Logger());

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  throw UnimplementedError(
    'preferencesStorageProvider must be overridden in main with the awaited instance',
  );
});

/// État d'auth : présence/absence du token.
final authTokenProvider = StateProvider<String?>((ref) => null);

final currentRoleProvider = StateProvider<String?>((ref) => null);

/// Builds a Dio client for [baseUrl] with the shared interceptors and the one logout-on-401.
Dio _createDio(Ref ref, String baseUrl) {
  final storage = ref.watch(secureStorageProvider);
  return HttpClientFactory.create(
    storage: storage,
    logger: ref.watch(loggerProvider),
    baseUrl: baseUrl,
    onUnauthorized: () async {
      await storage.delete(StorageKeys.authToken);
      ref.read(authTokenProvider.notifier).state = null;
    },
  );
}

/// Client of the API v1 (current screens).
final dioProvider = Provider<Dio>((ref) => _createDio(ref, Env.apiBaseUrl));

/// Client of the API v2 (envelope { data, meta, errors }): same interceptors, `/api/v2` base.
final dioV2Provider = Provider<Dio>((ref) => _createDio(ref, Env.apiV2BaseUrl));

final authGuardProvider = Provider<AuthGuard>((ref) {
  return AuthGuard(
    isAuthenticated: () => ref.read(authTokenProvider) != null,
    currentRole: () => ref.read(currentRoleProvider),
    onboardingDone: () => ref
        .read(preferencesStorageProvider)
        .readBool(StorageKeys.onboardingDoneFlag),
  );
});
