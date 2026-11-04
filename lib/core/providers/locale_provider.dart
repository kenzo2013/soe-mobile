import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/translations.g.dart';
import '../storage/preferences_storage.dart';
import '../storage/storage_keys.dart';
import 'core_providers.dart';

/// Current locale. A choice made in the app (FR / EN switch) is kept in
/// `PreferencesStorage` and wins; before any choice, the phone language is used
/// (first of its languages that is French or English), French otherwise.
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier(this._prefs, {List<Locale>? deviceLocales})
      : super(_load(
            _prefs, deviceLocales ?? PlatformDispatcher.instance.locales)) {
    LocaleSettings.setLocaleSync(state);
  }

  final PreferencesStorage _prefs;

  static AppLocale _load(PreferencesStorage prefs, List<Locale> deviceLocales) {
    final raw = prefs.readString(StorageKeys.preferredLang);
    final chosen = _match(raw);
    if (chosen != null) return chosen;
    for (final locale in deviceLocales) {
      final fromDevice = _match(locale.languageCode);
      if (fromDevice != null) return fromDevice;
    }
    return AppLocale.fr;
  }

  static AppLocale? _match(String? languageCode) {
    for (final locale in AppLocale.values) {
      if (locale.languageCode == languageCode) return locale;
    }
    return null;
  }

  Future<void> set(AppLocale locale) async {
    state = locale;
    await LocaleSettings.setLocale(locale);
    await _prefs.writeString(StorageKeys.preferredLang, locale.languageCode);
  }

  Future<void> toggle() async {
    await set(state == AppLocale.fr ? AppLocale.en : AppLocale.fr);
  }
}
