import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/push/push_client.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/storage/preferences_storage.dart';
import '../../auth/domain/entities/user.dart';
import '../../auth/presentation/providers.dart';
import '../../auth/presentation/providers/current_user_provider.dart';
import '../data/account_models.dart';
import 'notification_target_route.dart';

/// Binds this phone to the signed-in account for push notifications: OneSignal.login with the
/// account's `push_external_id` once signed in (and the account's language), OneSignal.logout
/// when the session ends (sign-out, expiry, deletion). The server targets that external id.
class PushSession {
  PushSession({
    required PushClient client,
    required bool Function() isSignedIn,
    required Future<User?> Function() cachedUser,
    required Future<User?> Function() freshUser,
  })  : _client = client,
        _isSignedIn = isSignedIn,
        _cachedUser = cachedUser,
        _freshUser = freshUser;

  final PushClient _client;
  final bool Function() _isSignedIn;
  final Future<User?> Function() _cachedUser;
  final Future<User?> Function() _freshUser;
  String? _boundId;

  /// After sign-in, at launch with a session, after a profile change. An account cached by an
  /// older build has no external id: it is read again from the API.
  Future<void> signedIn() async {
    if (!_client.enabled || !_isSignedIn()) return;
    var user = await _cachedUser();
    if (user?.pushExternalId?.isNotEmpty != true) user = await _freshUser();
    final externalId = user?.pushExternalId;
    if (externalId == null || externalId.isEmpty || !_isSignedIn()) return;
    if (externalId != _boundId) {
      await _client.login(externalId);
      _boundId = externalId;
    }
    final lang = user?.lang;
    if (lang != null && lang.isNotEmpty) await _client.setLanguage(lang);
  }

  /// No session (also at launch: a phone signed out while the app was closed stops receiving
  /// the former account's pushes).
  Future<void> signedOut() async {
    if (!_client.enabled) return;
    _boundId = null;
    await _client.logout();
  }
}

/// A push the user tapped: what the app opens (server data, see the API's « Push
/// notifications »).
class PushOpen {
  const PushOpen({this.notificationId, this.role, this.target});

  factory PushOpen.fromData(Map<String, dynamic> data) {
    final id = data['notification_id'];
    final target = data['target'];
    return PushOpen(
      notificationId: id is int ? id : int.tryParse('${id ?? ''}'),
      role: data['role'] as String?,
      target: target is Map
          ? NotificationTarget.fromJson(Map<String, dynamic>.from(target))
          : null,
    );
  }

  final int? notificationId;

  /// `parent` or `tutor`: the space the notification belongs to.
  final String? role;
  final NotificationTarget? target;

  /// The screen to open in the active [activeRole]: the target's, or the notification centre
  /// when the push belongs to the other space of a two-role account.
  String routeFor(String? activeRole) {
    if (role != null && activeRole != null && role != activeRole) {
      return RouteNames.notifications;
    }
    return notificationRoute(target, activeRole ?? role);
  }
}

/// The push tapped and not opened yet: the shell of the signed-in space opens it (PushGate).
final pendingPushOpenProvider = StateProvider<PushOpen?>((ref) => null);

/// Kept alive by the app: follows the session and receives the taps.
final pushSessionProvider = Provider<PushSession>((ref) {
  final client = ref.watch(pushClientProvider);
  final session = PushSession(
    client: client,
    isSignedIn: () => ref.read(authTokenProvider) != null,
    cachedUser: () => ref.read(currentUserProvider.future),
    freshUser: () async =>
        (await ref.read(authRepositoryProvider).fetchCurrentUser()).valueOrNull,
  );
  if (!client.enabled) return session;
  client.onOpened((data) => ref.read(pendingPushOpenProvider.notifier).state =
      PushOpen.fromData(data));
  ref
    ..listen<String?>(authTokenProvider, (_, token) {
      unawaited(token == null ? session.signedOut() : session.signedIn());
    }, fireImmediately: true)
    // A profile change (language) or a role switch reloads the account.
    ..listen<AsyncValue<User?>>(currentUserProvider, (_, user) {
      if (user.valueOrNull != null) unawaited(session.signedIn());
    });
  return session;
});

/// Asks once, after sign-in, whether the user wants notifications, with a word on why, before
/// the system prompt (never at first launch, before the user knows the app).
class PushPermissionPrompt {
  const PushPermissionPrompt(
      {required PushClient client, required PreferencesStorage prefs})
      : _client = client,
        _prefs = prefs;

  static const String askedKey = 'push_permission_asked';

  final PushClient _client;
  final PreferencesStorage _prefs;

  /// Not asked yet on this install, not granted, and the system can still ask.
  Future<bool> shouldAsk() async {
    if (!_client.enabled || _client.permissionGranted) return false;
    if (_prefs.readBool(askedKey)) return false;
    return _client.canRequestPermission();
  }

  /// [accepted]: the user chose « Activer » (then the system prompt). Asked once either way.
  Future<void> answered({required bool accepted}) async {
    await _prefs.writeBool(askedKey, value: true);
    if (accepted) await _client.requestPermission();
  }
}

final pushPermissionPromptProvider = Provider<PushPermissionPrompt>((ref) =>
    PushPermissionPrompt(
        client: ref.watch(pushClientProvider),
        prefs: ref.watch(preferencesStorageProvider)));
