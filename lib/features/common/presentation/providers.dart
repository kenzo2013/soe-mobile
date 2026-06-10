import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../core/providers/core_providers.dart';
import '../data/datasources/common_remote_datasource.dart';
import '../data/repositories/common_repository_impl.dart';
import '../domain/entities/account_address.dart';
import '../domain/entities/app_notification.dart';
import '../domain/entities/notification_preferences.dart';
import '../domain/entities/service_contract.dart';
import '../domain/repositories/common_repository.dart';

// ── Data ────────────────────────────────────────────────────
final commonRemoteDatasourceProvider = Provider<CommonRemoteDatasource>(
  (ref) => CommonRemoteDatasource(ref.watch(dioProvider)),
);

final commonRepositoryProvider = Provider<CommonRepository>(
  (ref) => CommonRepositoryImpl(
    remote: ref.watch(commonRemoteDatasourceProvider),
    storage: ref.watch(secureStorageProvider),
  ),
);

// ── Lectures (FutureProvider + AsyncValue.when côté View) ───
final accountAddressProvider =
    FutureProvider.autoDispose<AccountAddress>((ref) async {
  final r = await ref.watch(commonRepositoryProvider).getAddress();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

final notificationPreferencesProvider =
    FutureProvider.autoDispose<NotificationPreferences>((ref) async {
  final r =
      await ref.watch(commonRepositoryProvider).getNotificationPreferences();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

final notificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final r = await ref.watch(commonRepositoryProvider).getNotifications();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

final contractsProvider =
    FutureProvider.autoDispose<List<ServiceContract>>((ref) async {
  final r = await ref.watch(commonRepositoryProvider).getContracts();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
