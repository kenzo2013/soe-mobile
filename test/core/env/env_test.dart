import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/env/env.dart';

void main() {
  test('derives the v2 base URL from the v1 one', () {
    expect(Env.v2BaseUrlFrom('https://api.example.com/api/v1'),
        'https://api.example.com/api/v2');
    expect(Env.v2BaseUrlFrom('https://api.example.com/api/v1/'),
        'https://api.example.com/api/v2');
    expect(Env.v2BaseUrlFrom('https://tunnel.example.com'),
        'https://tunnel.example.com/api/v2');
    expect(Env.v2BaseUrlFrom(''), '');
  });

  test('has no default API URL (never staging by accident)', () {
    // Tests run without --dart-define: the URL must be empty and startup must refuse it.
    expect(Env.apiBaseUrl, isEmpty);
    expect(Env.ensureConfigured, throwsStateError);
  });
}
