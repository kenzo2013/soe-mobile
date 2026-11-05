import 'dart:io';

import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/storage_keys.dart';
import 'account_api.dart';

/// The push registration of this phone (`/api/v2/devices`). The push integration calls
/// [register] with the OneSignal player id once signed in; sign-out calls [unregister], which
/// does nothing when no device was registered.
class PushDevices {
  const PushDevices({required AccountApi api, required SecureStorage storage})
      : _api = api,
        _storage = storage;

  final AccountApi _api;
  final SecureStorage _storage;

  Future<void> register(String playerId,
      {String? appVersion, bool pushEnabled = true}) async {
    await _api.registerDevice(
      playerId: playerId,
      deviceType: Platform.isIOS ? 'ios' : 'android',
      osVersion: Platform.operatingSystemVersion,
      appVersion: appVersion,
      pushEnabled: pushEnabled,
    );
    await _storage.write(StorageKeys.pushPlayerId, playerId);
  }

  /// Best effort: a failure must never keep the user from signing out.
  Future<void> unregister() async {
    final playerId = await _storage.read(StorageKeys.pushPlayerId);
    if (playerId == null || playerId.isEmpty) return;
    try {
      await _api.unregisterDevice(playerId);
    } on Object catch (_) {
      // The server forgets the device when the token is revoked anyway.
    }
    await _storage.delete(StorageKeys.pushPlayerId);
  }
}
