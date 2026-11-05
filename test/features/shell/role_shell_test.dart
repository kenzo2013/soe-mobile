import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/presentation/providers/current_user_provider.dart';
import 'package:soe/features/shell/presentation/pages/more_page.dart';
import 'package:soe/features/shell/presentation/widgets/role_shell.dart';
import 'package:soe/i18n/translations.g.dart';

import '../../helpers/fake_api.dart';

const _tabs = [
  ShellTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
  ShellTab(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Planning'),
  ShellTab(icon: Icons.menu, activeIcon: Icons.menu_open, label: 'Plus'),
];

User _user({bool multiRole = false}) => User(
      id: '1',
      email: 'a@example.com',
      firstName: 'Awa',
      lastName: 'Ngono',
      role: UserRole.parent,
      multiRole: multiRole,
    );

Future<void> _pump(WidgetTester tester,
    {required Size size, User? user}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({StorageKeys.preferredLang: 'fr'});
  final prefs = PreferencesStorage(await SharedPreferences.getInstance());
  LocaleSettings.setLocaleSync(AppLocale.fr);
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            RoleShell(navigationShell: shell, tabs: _tabs),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const Text('home-tab'),
              routes: [
                GoRoute(
                    path: 'detail',
                    builder: (_, __) => const Text('home-detail'))
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/planning',
                builder: (_, __) => const Text('planning-tab'))
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const MorePage())
          ]),
        ],
      ),
      GoRoute(
          path: RouteNames.accountRoles,
          builder: (_, __) => const Text('role-switch')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesStorageProvider.overrideWithValue(prefs),
        dioV2Provider.overrideWithValue(FakeApi().dio),
        currentUserProvider.overrideWith((ref) async => user),
        currentRoleProvider.overrideWith((ref) => 'parent'),
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
}

void main() {
  testWidgets(
      'a phone shows the tab bar; each tab keeps its place, a second tap goes back to its start',
      (tester) async {
    await _pump(tester, size: const Size(390, 844));

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.text('home-tab'), findsOneWidget);
    GoRouter.of(tester.element(find.text('home-tab'))).go('/home/detail');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planning'));
    await tester.pumpAndSettle();
    expect(find.text('planning-tab'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(find.text('home-detail'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();
    expect(find.text('home-tab'), findsOneWidget);
  });

  testWidgets('a tablet shows a rail instead of the tab bar', (tester) async {
    await _pump(tester, size: const Size(834, 1194));

    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.text('Planning'));
    await tester.pumpAndSettle();
    expect(find.text('planning-tab'), findsOneWidget);
  });

  testWidgets(
      'on a phone, « Plus » opens its menu as a sheet over the open tab (PAR-01 « Menu Plus »)',
      (tester) async {
    await _pump(tester, size: const Size(390, 844), user: _user());
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();

    expect(find.text('home-tab'), findsOneWidget);
    expect(find.text('Demandes et devis'), findsOneWidget);
    expect(find.text('Contrats'), findsOneWidget);
    expect(find.text('Compte'), findsOneWidget);
    expect(find.text('Passer en mode répétiteur'), findsOneWidget);
    expect(find.text('Même compte, autre espace'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);

    await tester.tap(find.byTooltip('Fermer'));
    await tester.pumpAndSettle();
    expect(find.text('Demandes et devis'), findsNothing);
  });

  testWidgets('« Passer en mode répétiteur » opens the roles screen',
      (tester) async {
    await _pump(tester,
        size: const Size(390, 844), user: _user(multiRole: true));
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Passer en mode répétiteur'));
    await tester.pumpAndSettle();
    expect(find.text('role-switch'), findsOneWidget);
  });

  testWidgets(
      'on a tablet, « Plus » is the account hub with sign-out, without a switch for a single-role account',
      (tester) async {
    await _pump(tester, size: const Size(1024, 1366), user: _user());
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();

    expect(find.text('Awa Ngono'), findsOneWidget);
    expect(find.text('MODE PARENT · A@EXAMPLE.COM'), findsOneWidget);
    expect(find.text('Mon compte'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Se déconnecter'), 300,
        scrollable: find.byType(Scrollable).last);
    expect(find.text('Se déconnecter'), findsOneWidget);
    expect(find.text('Changer d’espace'), findsNothing);
  });
}
