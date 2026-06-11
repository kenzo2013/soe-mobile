import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/storage/preferences_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late PreferencesStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = PreferencesStorage(prefs);
  });

  group('String', () {
    test('readString retourne null par défaut', () {
      expect(storage.readString('missing'), isNull);
    });

    test('writeString puis readString round-trip', () async {
      await storage.writeString('lang', 'fr');

      expect(storage.readString('lang'), 'fr');
    });

    test('writeString retourne true', () async {
      final ok = await storage.writeString('k', 'v');

      expect(ok, isTrue);
    });
  });

  group('Bool', () {
    test('readBool retourne false par défaut', () {
      expect(storage.readBool('missing'), isFalse);
    });

    test('readBool respecte defaultValue', () {
      expect(storage.readBool('missing', defaultValue: true), isTrue);
    });

    test('writeBool puis readBool round-trip', () async {
      await storage.writeBool('flag', value: true);

      expect(storage.readBool('flag'), isTrue);
    });

    test('valeur stockée prime sur defaultValue', () async {
      await storage.writeBool('flag', value: false);

      expect(storage.readBool('flag', defaultValue: true), isFalse);
    });
  });

  group('remove', () {
    test('supprime une clé existante', () async {
      await storage.writeString('k', 'v');

      final removed = await storage.remove('k');

      expect(removed, isTrue);
      expect(storage.readString('k'), isNull);
    });
  });

  group('create', () {
    test('construit une instance depuis SharedPreferences.getInstance',
        () async {
      SharedPreferences.setMockInitialValues({'lang': 'en'});

      final created = await PreferencesStorage.create();

      expect(created.readString('lang'), 'en');
    });
  });
}
