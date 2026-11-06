import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the app needs from the push provider (OneSignal): the only seam between the app and the
/// SDK. [OneSignalPushClient] is the real one, [DisabledPushClient] stands in when the build has
/// no `ONESIGNAL_APP_ID` (development) and in tests.
///
/// The server targets the account's `push_external_id` (GET /me): [login] binds this phone to
/// it after sign-in, [logout] unbinds it at sign-out.
abstract interface class PushClient {
  /// False: every call does nothing (no SDK in this build).
  bool get enabled;

  Future<void> login(String externalId);

  Future<void> logout();

  /// The language of the texts OneSignal shows (`fr` or `en`), the account's.
  Future<void> setLanguage(String languageCode);

  /// The system already lets the app show notifications.
  bool get permissionGranted;

  /// The system prompt can still be shown (never answered).
  Future<bool> canRequestPermission();

  /// Shows the system prompt; true when granted.
  Future<bool> requestPermission();

  /// [handler] receives the additional data of each push the user taps (the server sends
  /// `notification_id`, `type`, `event`, `role` and `target`).
  void onOpened(void Function(Map<String, dynamic> data) handler);
}

/// The push client of the app, set in `bootstrap` (OneSignal when the build has an app id).
final pushClientProvider =
    Provider<PushClient>((ref) => const DisabledPushClient());

/// No push notifications: a build without OneSignal app id, and the tests.
class DisabledPushClient implements PushClient {
  const DisabledPushClient();

  @override
  bool get enabled => false;

  @override
  Future<void> login(String externalId) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> setLanguage(String languageCode) async {}

  @override
  bool get permissionGranted => false;

  @override
  Future<bool> canRequestPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  void onOpened(void Function(Map<String, dynamic> data) handler) {}
}
