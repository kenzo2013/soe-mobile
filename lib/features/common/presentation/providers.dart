import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/account_api.dart';
import '../data/account_models.dart';
import '../data/push_devices.dart';

// ── Account and common screens (API v2) ────────────────────

final accountApiProvider =
    Provider<AccountApi>((ref) => AccountApi(ref.watch(dioV2Provider)));

final pushDevicesProvider = Provider<PushDevices>((ref) => PushDevices(
    api: ref.watch(accountApiProvider),
    storage: ref.watch(secureStorageProvider)));

final accountAddressProvider = FutureProvider.autoDispose<AccountAddress>(
    (ref) => ref.watch(accountApiProvider).address());

final accountRolesProvider = FutureProvider.autoDispose<AccountRoles>(
    (ref) => ref.watch(accountApiProvider).roles());

final deletionCheckProvider = FutureProvider.autoDispose<DeletionCheck>(
    (ref) => ref.watch(accountApiProvider).deletionCheck());

final notificationPreferencesProvider =
    FutureProvider.autoDispose<NotificationPreferences>(
        (ref) => ref.watch(accountApiProvider).notificationPreferences());

/// The badge of the bell: unread notifications of the active role. Refreshed after each action
/// of the notification centre, and when the role or the session changes.
/// Signed out (no token), it asks nothing: the bell still on screen while the sign-out runs
/// must not call the API with the revoked session (a 401 after sign-out).
final unreadNotificationsProvider = FutureProvider.autoDispose<int>((ref) {
  final token = ref.watch(authTokenProvider);
  ref.watch(currentRoleProvider);
  if (token == null) return Future.value(0);
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
