import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper testable autour de `flutter_secure_storage`.
///
/// Tokens et données sensibles uniquement. Cf. REBUILD_SPEC §8.1.6.
class SecureStorage {
  SecureStorage([FlutterSecureStorage? inner])
      : _inner = inner ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _inner;

  Future<String?> read(String key) => _inner.read(key: key);

  Future<void> write(String key, String value) =>
      _inner.write(key: key, value: value);

  Future<void> delete(String key) => _inner.delete(key: key);

  Future<void> clear() => _inner.deleteAll();
}
