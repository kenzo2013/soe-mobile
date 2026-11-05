import 'dart:ui' show Locale;

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/translations.g.dart';
import '../storage/preferences_storage.dart';
import '../storage/storage_keys.dart';
import 'core_providers.dart';

/// Current locale: the phone's language, with no switch in the app. French when the phone
/// speaks French (`fr`, `fr_CM`…), English otherwise. The API receives it on every request
/// (`Accept-Language`, see `LocaleInterceptor`).
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return LocaleNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier(PreferencesStorage prefs, {List<Locale>? deviceLocales})
      : super(fromDevice(deviceLocales ??
            WidgetsBinding.instance.platformDispatcher.locales)) {
    LocaleSettings.setLocaleSync(state);
    // A choice kept by an earlier version (FR / EN switch) no longer applies.
    if (prefs.readString(StorageKeys.preferredLang) != null) {
      prefs.remove(StorageKeys.preferredLang).ignore();
    }
  }

  /// The language of the phone's first locale: French for `fr*`, English otherwise.
  static AppLocale fromDevice(List<Locale> deviceLocales) {
    final first = deviceLocales.isEmpty ? null : deviceLocales.first;
    return first?.languageCode == 'fr' ? AppLocale.fr : AppLocale.en;
  }
}
