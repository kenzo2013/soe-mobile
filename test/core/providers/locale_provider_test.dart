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

  test('before any choice, follows the phone language', () async {
    final notifier = LocaleNotifier(await _prefs(),
        deviceLocales: const [Locale('en', 'CM')]);

    expect(notifier.state, AppLocale.en);
  });

  test('takes the first phone language that the app speaks', () async {
    final notifier = LocaleNotifier(await _prefs(),
        deviceLocales: const [Locale('pt'), Locale('fr', 'CM'), Locale('en')]);

    expect(notifier.state, AppLocale.fr);
  });

  test('French when the phone speaks neither French nor English', () async {
    final notifier =
        LocaleNotifier(await _prefs(), deviceLocales: const [Locale('de')]);

    expect(notifier.state, AppLocale.fr);
  });

  test('a choice made in the app wins over the phone language and is kept',
      () async {
    final prefs = await _prefs({StorageKeys.preferredLang: 'fr'});
    final notifier = LocaleNotifier(prefs, deviceLocales: const [Locale('en')]);

    expect(notifier.state, AppLocale.fr);
    await notifier.toggle();

    expect(prefs.readString(StorageKeys.preferredLang), 'en');
  });
}
