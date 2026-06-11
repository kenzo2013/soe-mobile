import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/storage/secure_storage.dart';

class _MockSecure extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecure inner;
  late SecureStorage storage;

  setUp(() {
    inner = _MockSecure();
    storage = SecureStorage(inner);
  });

  group('read', () {
    test('délègue à inner.read avec la bonne clé', () async {
      when(() => inner.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'value');

      final result = await storage.read('my_key');

      expect(result, 'value');
      verify(() => inner.read(key: 'my_key')).called(1);
    });

    test('retourne null quand la clé n\'existe pas', () async {
      when(() => inner.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await storage.read('missing');

      expect(result, isNull);
    });
  });

  group('write', () {
    test('délègue à inner.write avec clé et valeur', () async {
      when(() => inner.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await storage.write('k', 'v');

      verify(() => inner.write(key: 'k', value: 'v')).called(1);
    });
  });

  group('delete', () {
    test('délègue à inner.delete avec la clé', () async {
      when(() => inner.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      await storage.delete('k');

      verify(() => inner.delete(key: 'k')).called(1);
    });
  });

  group('clear', () {
    test('délègue à inner.deleteAll', () async {
      when(() => inner.deleteAll()).thenAnswer((_) async {});

      await storage.clear();

      verify(() => inner.deleteAll()).called(1);
    });
  });
}
