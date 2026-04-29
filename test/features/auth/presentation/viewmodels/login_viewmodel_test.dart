import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/features/auth/domain/entities/auth_session.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/usecases/login.dart';
import 'package:soe/features/auth/presentation/providers.dart';
import 'package:soe/features/auth/presentation/viewmodels/auth_state.dart';
import 'package:soe/features/auth/presentation/viewmodels/login_viewmodel.dart';

import '../../../../helpers/test_di.dart';

class _MockLogin extends Mock implements Login {}

class _FakeSecureStorage implements SecureStorage {
  final Map<String, String> _store = {};
  @override
  Future<String?> read(String key) async => _store[key];
  @override
  Future<void> write(String key, String value) async => _store[key] = value;
  @override
  Future<void> delete(String key) async => _store.remove(key);
  @override
  Future<void> clear() async => _store.clear();
}

void main() {
  late _MockLogin login;

  setUp(() {
    login = _MockLogin();
  });

  AuthSession session() => const AuthSession(
        user: User(
          id: '1',
          email: 'a@b.com',
          firstName: 'Jean',
          lastName: 'Dupont',
          role: UserRole.parent,
        ),
        accessToken: 'tok',
      );

  test('initial state is AuthState.initial', () {
    final c = makeContainer(overrides: [
      loginUsecaseProvider.overrideWithValue(login),
      secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
    ]);
    expect(c.read(loginViewModelProvider), const AuthState.initial());
  });

  test('emits loading -> authenticated on success', () async {
    when(() => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Ok(session()));

    final c = makeContainer(overrides: [
      loginUsecaseProvider.overrideWithValue(login),
      secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
    ]);

    final f = c
        .read(loginViewModelProvider.notifier)
        .submit(email: 'a@b.com', password: 'secret123');
    expect(c.read(loginViewModelProvider), const AuthState.loading());
    await f;
    final after = c.read(loginViewModelProvider);
    expect(after, AuthState.authenticated(session()));
  });

  test('emits loading -> error on failure', () async {
    when(() => login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => const Err(UnauthorizedFailure()));

    final c = makeContainer(overrides: [
      loginUsecaseProvider.overrideWithValue(login),
      secureStorageProvider.overrideWithValue(_FakeSecureStorage()),
    ]);

    await c
        .read(loginViewModelProvider.notifier)
        .submit(email: 'a@b.com', password: 'wrong');
    expect(
      c.read(loginViewModelProvider),
      const AuthState.error(UnauthorizedFailure()),
    );
  });
}
