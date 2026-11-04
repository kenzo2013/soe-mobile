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
          path: RouteNames.accountRole,
          builder: (_, __) => const Text('role-switch')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesStorageProvider.overrideWithValue(prefs),
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
      '« Plus » lists the account and sign-out, without a switch for a single-role account',
      (tester) async {
    await _pump(tester, size: const Size(390, 844), user: _user());
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();

    expect(find.text('Awa Ngono'), findsOneWidget);
    expect(find.text('Espace parent'), findsOneWidget);
    expect(find.text('Mon compte'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
    expect(find.text('Changer d’espace'), findsNothing);
  });

  testWidgets('a multi-role account can switch space from « Plus »',
      (tester) async {
    await _pump(tester,
        size: const Size(390, 844), user: _user(multiRole: true));
    await tester.tap(find.text('Plus').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Changer d’espace'));
    await tester.pumpAndSettle();
    expect(find.text('role-switch'), findsOneWidget);
  });
}
