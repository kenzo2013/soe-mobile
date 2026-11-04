import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/env/env.dart';
import 'package:soe/core/network/image_url.dart';

void main() {
  test('derives the v2 base URL from the v1 one', () {
    expect(Env.v2BaseUrlFrom('https://api.example.com/api/v1'),
        'https://api.example.com/api/v2');
    expect(Env.v2BaseUrlFrom('https://api.example.com/api/v1/'),
        'https://api.example.com/api/v2');
    expect(Env.v2BaseUrlFrom('https://tunnel.example.com'),
        'https://tunnel.example.com/api/v2');
    expect(Env.v2BaseUrlFrom('http://localhost:3000/api/v1'),
        'http://localhost:3000/api/v2');
  });

  test('refuses URLs it cannot turn into the v2 base', () {
    expect(Env.v2BaseUrlFrom(''), isNull);
    expect(Env.v2BaseUrlFrom('https://host/api'), isNull);
    expect(Env.v2BaseUrlFrom('https://host/api/v1.json'), isNull);
    expect(Env.v2BaseUrlFrom('not a url'), isNull);
  });

  test(
      'ensureConfigured refuses a missing or invalid URL and accepts a v1 base',
      () {
    expect(() => Env.ensureConfigured(''), throwsStateError);
    expect(() => Env.ensureConfigured('https://host/api'), throwsStateError);
    expect(() => Env.ensureConfigured('https://host/api/v1'), returnsNormally);
  });

  test(
      'ImageUrl resolves relative paths against the origin and never crashes without one',
      () {
    expect(ImageUrl.resolve('/rails/blob.jpg', origin: 'https://h.example'),
        'https://h.example/rails/blob.jpg');
    expect(ImageUrl.resolve('https://cdn.example/a.jpg'),
        'https://cdn.example/a.jpg');
    expect(ImageUrl.resolve(null), isNull);
  });
}
