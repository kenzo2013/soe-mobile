import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/push/push_client.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/features/common/data/account_models.dart';
import 'package:soe/features/common/presentation/push_session.dart';
import 'package:soe/features/common/presentation/widgets/push_gate.dart';
import 'package:soe/i18n/translations.g.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/fake_push_client.dart';

/// The signed-in space (`/parent`) inside a PushGate, and a stand-in for the screens a push opens.
Future<(GoRouter, FakeApi)> _pumpSpace(WidgetTester tester,
    {required PushClient client, PushOpen? pending}) async {
  tester.view.physicalSize = const Size(700, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesStorage(await SharedPreferences.getInstance());
  LocaleSettings.setLocaleSync(AppLocale.fr);
  final api = FakeApi();
  final router = GoRouter(
    initialLocation: '/parent',
    routes: [
      GoRoute(
          path: '/parent',
          builder: (_, __) =>
              const PushGate(child: Scaffold(body: Text('home')))),
      GoRoute(
          path: '/parent/space/payments/:id',
          builder: (_, state) => Scaffold(body: Text('screen ${state.uri}'))),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      pushClientProvider.overrideWithValue(client),
      preferencesStorageProvider.overrideWithValue(prefs),
      dioV2Provider.overrideWithValue(api.dio),
      currentRoleProvider.overrideWith((ref) => 'parent'),
      pendingPushOpenProvider.overrideWith((ref) => pending),
    ],
    child: TranslationProvider(
      child: MaterialApp.router(
        theme: AppTheme.light(),
        routerConfig: router,
        locale: AppLocale.fr.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    ),
  ));
  await tester.pumpAndSettle();
  return (router, api);
}

void main() {
  testWidgets('explains why, then shows the system prompt on « Activer »',
      (tester) async {
    final client = FakePushClient();
    await _pumpSpace(tester, client: client);

    expect(find.text('Recevoir les notifications ?'), findsOneWidget);
    await tester.tap(find.text('Activer'));
    await tester.pumpAndSettle();

    expect(client.calls, ['requestPermission']);
    expect(find.text('Recevoir les notifications ?'), findsNothing);
  });

  testWidgets('« Plus tard » closes without the system prompt', (tester) async {
    final client = FakePushClient();
    await _pumpSpace(tester, client: client);

    await tester.tap(find.text('Plus tard'));
    await tester.pumpAndSettle();

    expect(client.calls, isEmpty);
  });

  testWidgets('a tapped push opens its screen and marks it read',
      (tester) async {
    final (_, api) = await _pumpSpace(
      tester,
      client: FakePushClient(granted: true),
      pending: const PushOpen(
          notificationId: 12,
          role: 'parent',
          target: NotificationTarget(kind: 'payment', id: 3)),
    );

    expect(find.text('screen /parent/space/payments/3'), findsOneWidget);
    expect(api.sent('POST /notifications/12/read'), hasLength(1));
  });

  testWidgets('a build without push notifications asks nothing',
      (tester) async {
    await _pumpSpace(tester, client: const DisabledPushClient());

    expect(find.text('home'), findsOneWidget);
    expect(find.text('Recevoir les notifications ?'), findsNothing);
  });
}
