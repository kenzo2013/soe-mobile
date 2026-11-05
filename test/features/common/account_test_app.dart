import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/presentation/providers/current_user_provider.dart';
import 'package:soe/features/common/presentation/routes.dart';
import 'package:soe/features/shell/presentation/pages/more_page.dart';
import 'package:soe/i18n/translations.g.dart';

import '../../helpers/fake_api.dart';

User accountUser({
  UserRole role = UserRole.parent,
  bool multiRole = false,
  String phone = '677452109',
}) =>
    User(
      id: '1',
      email: 'mireille.mbarga@gmail.com',
      firstName: 'Mireille',
      lastName: 'Mbarga',
      role: role,
      civility: 'mrs',
      phone: phone,
      lang: 'fr',
      multiRole: multiRole,
    );

/// The account screens in a router: the common routes, « Plus » at `/more`, and a stand-in for
/// each screen a notification or a role change may open (it shows its path).
Future<GoRouter> pumpAccountApp(
  WidgetTester tester, {
  required FakeApi api,
  required String location,
  User? user,
  String role = 'parent',
  MemoryStorage? storage,
}) async {
  // Wider than a phone: the test font draws every glyph as a square, wider than Figtree.
  tester.view.physicalSize = const Size(700, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesStorage(await SharedPreferences.getInstance());
  LocaleSettings.setLocaleSync(AppLocale.fr);
  Widget stand(BuildContext context, GoRouterState state) =>
      Scaffold(body: Text('screen ${state.uri}'));
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(path: '/more', builder: (_, __) => const MorePage()),
      ...commonRoutes(),
      for (final path in [
        '/login',
        '/parent',
        '/parent/payments',
        '/parent/space/sessions/:id',
        '/parent/space/sessions/:id/report',
        '/parent/space/requests',
        '/tutor',
        '/tutor/space/proposals/:id',
      ])
        GoRoute(path: path, builder: stand),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dioV2Provider.overrideWithValue(api.dio),
        secureStorageProvider.overrideWithValue(storage ?? MemoryStorage()),
        preferencesStorageProvider.overrideWithValue(prefs),
        currentUserProvider.overrideWith((ref) async => user ?? accountUser()),
        currentRoleProvider.overrideWith((ref) => role),
        authTokenProvider.overrideWith((ref) => 'jwt'),
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
    ),
  );
  await tester.pumpAndSettle();
  return router;
}
