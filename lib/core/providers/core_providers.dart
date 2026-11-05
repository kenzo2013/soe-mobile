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

/// Set when the API refused the stored session (401 with a token): the app goes back to the
/// sign-in, which shows « Votre session a expiré » (AUT-11) until the next sign-in.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);

/// Builds a Dio client for [baseUrl] with the shared interceptors and the one logout-on-401.
Dio _createDio(Ref ref, String baseUrl) {
  final storage = ref.watch(secureStorageProvider);
  return HttpClientFactory.create(
    storage: storage,
    logger: ref.watch(loggerProvider),
    baseUrl: baseUrl,
    onUnauthorized: () async {
      // A 401 without a stored session is a refused sign-in (wrong password), not an expiry.
      final token = await storage.read(StorageKeys.authToken);
      if (token == null || token.isEmpty) return;
      await storage.delete(StorageKeys.authToken);
      ref.read(sessionExpiredProvider.notifier).state = true;
      ref.read(authTokenProvider.notifier).state = null;
    },
  );
}

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
