import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'push_client.dart';

/// The OneSignal SDK behind [PushClient]: the only file of the app that calls it.
class OneSignalPushClient implements PushClient {
  OneSignalPushClient._();

  /// Initializes the SDK with [appId] (`Env.oneSignalAppId`), before `runApp`. It asks for no
  /// permission: the app explains why after sign-in (PushPermissionPrompt).
  static Future<OneSignalPushClient> start(String appId) async {
    if (kDebugMode) await OneSignal.Debug.setLogLevel(OSLogLevel.info);
    await OneSignal.initialize(appId);
    return OneSignalPushClient._();
  }

  @override
  bool get enabled => true;

  @override
  Future<void> login(String externalId) => OneSignal.login(externalId);

  @override
  Future<void> logout() => OneSignal.logout();

  @override
  Future<void> setLanguage(String languageCode) =>
      OneSignal.User.setLanguage(languageCode);

  @override
  bool get permissionGranted => OneSignal.Notifications.permission;

  @override
  Future<bool> canRequestPermission() => OneSignal.Notifications.canRequest();

  @override
  Future<bool> requestPermission() =>
      OneSignal.Notifications.requestPermission(false);

  @override
  void onOpened(void Function(Map<String, dynamic> data) handler) {
    OneSignal.Notifications.addClickListener(
      (event) => handler(event.notification.additionalData ?? const {}),
    );
  }
}
