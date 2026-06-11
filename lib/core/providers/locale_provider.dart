import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/translations.g.dart';
import '../storage/preferences_storage.dart';
import '../storage/storage_keys.dart';
import 'core_providers.dart';

/// Locale courante. Persistée dans `PreferencesStorage`. Défaut : FR.
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier(this._prefs) : super(_load(_prefs)) {
    LocaleSettings.setLocaleSync(state);
  }

  final PreferencesStorage _prefs;

  static AppLocale _load(PreferencesStorage prefs) {
    final raw = prefs.readString(StorageKeys.preferredLang);
    if (raw == null) return AppLocale.fr;
    return AppLocale.values.firstWhere(
      (l) => l.languageCode == raw,
      orElse: () => AppLocale.fr,
    );
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
