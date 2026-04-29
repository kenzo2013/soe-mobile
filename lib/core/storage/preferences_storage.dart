import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper autour de `SharedPreferences` pour les préférences non sensibles.
class PreferencesStorage {
  PreferencesStorage(this._prefs);
  final SharedPreferences _prefs;

  static Future<PreferencesStorage> create() async {
    final p = await SharedPreferences.getInstance();
    return PreferencesStorage(p);
  }

  String? readString(String key) => _prefs.getString(key);
  Future<bool> writeString(String key, String value) =>
      _prefs.setString(key, value);

  bool readBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;
  Future<bool> writeBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
