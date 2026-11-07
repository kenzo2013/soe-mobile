import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/app/bootstrap.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/push/push_client.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/presentation/providers/current_user_provider.dart';
import 'package:soe/features/common/presentation/push_session.dart';
import 'package:soe/features/parent_space/presentation/parent_space_routes.dart';

import '../../helpers/fake_push_client.dart';

User _user({String? pushExternalId = 'ext-1', String lang = 'en'}) => User(
      id: '7',
      email: 'parent@example.com',
      firstName: 'Awa',
      lastName: 'Ngo',
      role: UserRole.parent,
      lang: lang,
      pushExternalId: pushExternalId,
    );

void main() {
  group('PushSession', () {
    late FakePushClient client;
    var signedIn = true;
    User? cached;
    User? fresh;

    PushSession session() => PushSession(
          client: client,
          isSignedIn: () => signedIn,
          cachedUser: () async => cached,
          freshUser: () async => fresh,
        );

    setUp(() {
      client = FakePushClient();
      signedIn = true;
      cached = _user();
      fresh = null;
    });

    test('binds the phone to the account external id, in its language',
        () async {
      await session().signedIn();

      expect(client.calls, ['login:ext-1', 'language:en']);
    });

    test('logs in once for the same account', () async {
      final push = session();
      await push.signedIn();
      await push.signedIn();

      expect(client.calls.where((call) => call.startsWith('login')).length, 1);
    });

    test('reads the account again when the cache has no external id', () async {
      cached = _user(pushExternalId: null);
      fresh = _user(pushExternalId: 'ext-2', lang: 'fr');

      await session().signedIn();

      expect(client.calls, ['login:ext-2', 'language:fr']);
    });

    test('does nothing without session or external id', () async {
      signedIn = false;
      await session().signedIn();
      signedIn = true;
      cached = _user(pushExternalId: null);
      await session().signedIn();

      expect(client.calls, isEmpty);
    });

    test('unbinds the phone at sign-out', () async {
      final push = session();
      await push.signedIn();
      await push.signedOut();
      await push.signedIn();

      expect(client.calls, [
        'login:ext-1',
        'language:en',
        'logout',
        'login:ext-1',
        'language:en'
      ]);
    });

    test('a build without push notifications calls nothing', () async {
      final push = PushSession(
        client: const DisabledPushClient(),
        isSignedIn: () => true,
        cachedUser: () async => _user(),
        freshUser: () async => null,
      );

      await push.signedIn();
      await push.signedOut();
    });
  });

  group('pushSessionProvider', () {
    test('follows the session token and receives the taps', () async {
      final client = FakePushClient();
      final container = ProviderContainer(overrides: [
        pushClientProvider.overrideWithValue(client),
        currentUserProvider.overrideWith((ref) async {
          ref.watch(authTokenProvider);
          return _user();
        }),
      ]);
      addTearDown(container.dispose);

      container.read(pushSessionProvider);
      await pumpEventQueue();
      expect(client.calls, ['logout'], reason: 'no session at launch');

      container.read(authTokenProvider.notifier).state = 'jwt';
      await pumpEventQueue();
      expect(client.calls, contains('login:ext-1'));

      container.read(authTokenProvider.notifier).state = null;
      await pumpEventQueue();
      expect(client.calls.last, 'logout');

      client.openedHandler!({
        'notification_id': 12,
        'role': 'parent',
        'target': {'kind': 'payment', 'id': 3},
      });
      final open = container.read(pendingPushOpenProvider);
      expect(open?.notificationId, 12);
      expect(open?.target?.kind, 'payment');
    });
  });

  group('PushOpen', () {
    test('opens the target screen in the active role', () {
      final open = PushOpen.fromData({
        'notification_id': '12',
        'type': 'payment',
        'role': 'parent',
        'target': <Object?, Object?>{'kind': 'payment', 'id': 3},
      });

      expect(open.notificationId, 12);
      expect(open.routeFor('parent'), ParentSpaceRoutes.payment(3));
    });

    test('without target: the home of the space', () {
      expect(PushOpen.fromData({'role': 'tutor'}).routeFor('tutor'),
          RouteNames.tutorHome);
      expect(PushOpen.fromData(const {}).routeFor(null), RouteNames.parentHome);
    });

    test('a push of the other space opens the notification centre', () {
      final open = PushOpen.fromData({
        'role': 'parent',
        'target': {'kind': 'payment', 'id': 3},
      });

      expect(open.routeFor('tutor'), RouteNames.notifications);
    });
  });

  group('PushPermissionPrompt', () {
    Future<PreferencesStorage> prefs(
        [Map<String, Object> values = const {}]) async {
      SharedPreferences.setMockInitialValues(values);
      return PreferencesStorage(await SharedPreferences.getInstance());
    }

    test('asks once, then shows the system prompt when accepted', () async {
      final client = FakePushClient();
      final prompt = PushPermissionPrompt(client: client, prefs: await prefs());

      expect(await prompt.shouldAsk(), isTrue);
      await prompt.answered(accepted: true);

      expect(client.calls, ['requestPermission']);
      expect(await prompt.shouldAsk(), isFalse);
    });

    test('« Plus tard » does not show the system prompt nor ask again',
        () async {
      final client = FakePushClient();
      final prompt = PushPermissionPrompt(client: client, prefs: await prefs());

      await prompt.answered(accepted: false);

      expect(client.calls, isEmpty);
      expect(await prompt.shouldAsk(), isFalse);
    });

    test('not asked when granted, refused for good, or without push', () async {
      final storage = await prefs();
      expect(
          await PushPermissionPrompt(
                  client: FakePushClient(granted: true), prefs: storage)
              .shouldAsk(),
          isFalse);
      expect(
          await PushPermissionPrompt(
                  client: FakePushClient(canRequest: false), prefs: storage)
              .shouldAsk(),
          isFalse);
      expect(
          await PushPermissionPrompt(
                  client: const DisabledPushClient(), prefs: storage)
              .shouldAsk(),
          isFalse);
    });
  });

  test('a build without OneSignal app id starts without push', () async {
    expect((await startPush('')).enabled, isFalse);
  });

  test('the account gives its push external id', () {
    final user = AuthRepositoryImpl.userFromApi({
      'id': 7,
      'email': 'parent@example.com',
      'current_role': 'parent',
      'roles': ['parent'],
      'push_external_id': '3f2b1c4e-0000-4000-8000-000000000000',
    });

    expect(user.pushExternalId, '3f2b1c4e-0000-4000-8000-000000000000');
  });
}
