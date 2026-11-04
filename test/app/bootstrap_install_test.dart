import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/app/bootstrap.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';

class _Secure extends Mock implements SecureStorage {}

Future<PreferencesStorage> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return PreferencesStorage(await SharedPreferences.getInstance());
}

void main() {
  late _Secure secure;

  setUp(() {
    secure = _Secure();
    when(() => secure.clear()).thenAnswer((_) async {});
  });

  test('a fresh install forgets the session the iOS keychain kept', () async {
    final prefs = await _prefs({});

    await forgetSessionOfPreviousInstall(prefs, secure);

    verify(() => secure.clear()).called(1);
    expect(prefs.readBool(StorageKeys.installMarker), isTrue);
  });

  test('an app update keeps its session', () async {
    await forgetSessionOfPreviousInstall(
        await _prefs({StorageKeys.onboardingDoneFlag: true}), secure);
    await forgetSessionOfPreviousInstall(
        await _prefs({StorageKeys.installMarker: true}), secure);

    verifyNever(() => secure.clear());
  });
}
