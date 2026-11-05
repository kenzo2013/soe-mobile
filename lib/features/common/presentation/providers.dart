import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../core/providers/core_providers.dart';
import '../data/account_api.dart';
import '../data/account_models.dart';
import '../data/datasources/common_remote_datasource.dart';
import '../data/push_devices.dart';
import '../data/repositories/common_repository_impl.dart';
import '../domain/entities/service_contract.dart';
import '../domain/repositories/common_repository.dart';

// ── Account and common screens (API v2) ────────────────────

final accountApiProvider =
    Provider<AccountApi>((ref) => AccountApi(ref.watch(dioV2Provider)));

final pushDevicesProvider = Provider<PushDevices>((ref) => PushDevices(
    api: ref.watch(accountApiProvider),
    storage: ref.watch(secureStorageProvider)));

final accountAddressProvider = FutureProvider.autoDispose<AccountAddress>(
    (ref) => ref.watch(accountApiProvider).address());

final cityNamesProvider = FutureProvider.autoDispose<List<String>>(
    (ref) => ref.watch(accountApiProvider).cities());

final accountRolesProvider = FutureProvider.autoDispose<AccountRoles>(
    (ref) => ref.watch(accountApiProvider).roles());

final deletionCheckProvider = FutureProvider.autoDispose<DeletionCheck>(
    (ref) => ref.watch(accountApiProvider).deletionCheck());

final notificationPreferencesProvider =
    FutureProvider.autoDispose<NotificationPreferences>(
        (ref) => ref.watch(accountApiProvider).notificationPreferences());

/// The badge of the bell: unread notifications of the active role. Refreshed after each action
/// of the notification centre, and when the role or the session changes.
final unreadNotificationsProvider = FutureProvider.autoDispose<int>((ref) {
  ref.watch(authTokenProvider);
  ref.watch(currentRoleProvider);
  return ref.watch(accountApiProvider).unreadCount();
});

/// The notification centre for a filter: `all`, `unread` or `todo`.
final notificationsProvider = FutureProvider.autoDispose
    .family<NotificationPage, String>((ref, filter) =>
        ref.watch(accountApiProvider).notifications(filter: filter));

final reportReasonsProvider = FutureProvider.autoDispose<ReportReasons>(
    (ref) => ref.watch(accountApiProvider).reportReasons());

final reportSessionsProvider = FutureProvider.autoDispose<List<ReportSession>>(
    (ref) => ref.watch(accountApiProvider).reportSessions());

final reportsProvider = FutureProvider.autoDispose<List<ProblemReport>>(
    (ref) => ref.watch(accountApiProvider).reports());

final reportProvider = FutureProvider.autoDispose.family<ProblemReport, int>(
    (ref, id) => ref.watch(accountApiProvider).report(id));

final helpProvider = FutureProvider.autoDispose<HelpContent>(
    (ref) => ref.watch(accountApiProvider).help());

// ── Legacy contracts (API v1, read by the v1 parent and tutor screens) ──

final commonRemoteDatasourceProvider = Provider<CommonRemoteDatasource>(
  (ref) => CommonRemoteDatasource(ref.watch(dioProvider)),
);

final commonRepositoryProvider = Provider<CommonRepository>(
  (ref) =>
      CommonRepositoryImpl(remote: ref.watch(commonRemoteDatasourceProvider)),
);

final contractsProvider =
    FutureProvider.autoDispose<List<ServiceContract>>((ref) async {
  final r = await ref.watch(commonRepositoryProvider).getContracts();
  return switch (r) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
