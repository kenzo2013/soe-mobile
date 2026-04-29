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

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  return HttpClientFactory.create(
    storage: storage,
    logger: logger,
    onUnauthorized: () async {
      await storage.delete(StorageKeys.authToken);
      ref.read(authTokenProvider.notifier).state = null;
    },
  );
});

final authGuardProvider = Provider<AuthGuard>((ref) {
  return AuthGuard(
    isAuthenticated: () => ref.read(authTokenProvider) != null,
    currentRole: () => ref.read(currentRoleProvider),
    onboardingDone: () =>
        ref.read(preferencesStorageProvider).readBool(StorageKeys.onboardingDoneFlag),
  );
});
