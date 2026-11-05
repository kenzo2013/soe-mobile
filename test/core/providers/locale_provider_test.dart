import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/providers/locale_provider.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';
import 'package:soe/i18n/translations.g.dart';

Future<PreferencesStorage> _prefs(
    [Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return PreferencesStorage(await SharedPreferences.getInstance());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('French when the phone speaks French', () async {
    final notifier = LocaleNotifier(await _prefs(),
        deviceLocales: const [Locale('fr', 'CM')]);

    expect(notifier.state, AppLocale.fr);
  });

  test('English when the phone speaks English', () async {
    final notifier = LocaleNotifier(await _prefs(),
        deviceLocales: const [Locale('en', 'CM')]);

    expect(notifier.state, AppLocale.en);
  });

  test('English when the phone speaks neither French nor English', () async {
    final notifier = LocaleNotifier(await _prefs(),
        deviceLocales: const [Locale('pt'), Locale('fr')]);

    expect(notifier.state, AppLocale.en);
  });

  test('a choice kept by an earlier version is ignored and forgotten',
      () async {
    final prefs = await _prefs({StorageKeys.preferredLang: 'en'});
    final notifier = LocaleNotifier(prefs, deviceLocales: const [Locale('fr')]);

    expect(notifier.state, AppLocale.fr);
    await Future<void>.delayed(Duration.zero);
    expect(prefs.readString(StorageKeys.preferredLang), isNull);
  });
}
