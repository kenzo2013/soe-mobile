import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/network/image_url.dart';

void main() {
  // Origin attendu = scheme://host du défaut Env.apiBaseUrl
  // (https://api.jeteste.site/api/v1) → https://api.jeteste.site
  const origin = 'https://api.jeteste.site';

  group('ImageUrl.resolve', () {
    test('null → null', () {
      expect(ImageUrl.resolve(null), isNull);
    });

    test('chaîne vide → null', () {
      expect(ImageUrl.resolve(''), isNull);
    });

    test('URL déjà absolue (https) renvoyée telle quelle', () {
      const abs = 'https://cdn.example.com/photo.jpg';
      expect(ImageUrl.resolve(abs), abs);
    });

    test('URL déjà absolue (http) renvoyée telle quelle', () {
      const abs = 'http://cdn.example.com/photo.jpg';
      expect(ImageUrl.resolve(abs), abs);
    });

    test('chemin relatif commençant par / préfixé par origin sans double slash',
        () {
      expect(
        ImageUrl.resolve('/rails/active_storage/blobs/redirect/photo.jpg'),
        '$origin/rails/active_storage/blobs/redirect/photo.jpg',
      );
    });

    test('chemin relatif sans / initial → ajoute le slash séparateur', () {
      expect(
        ImageUrl.resolve('uploads/avatar.png'),
        '$origin/uploads/avatar.png',
      );
    });
  });
}
