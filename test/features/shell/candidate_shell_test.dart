import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/core/widgets/soe_bottom_nav.dart';
import 'package:soe/features/shell/presentation/routes.dart';
import 'package:soe/features/shell/presentation/widgets/role_shell.dart';
import 'package:soe/i18n/translations.g.dart';

/// The tutor shell with stand-in screens: 0 home (the candidate's file under it), 1 to 3 the
/// active tabs, 4 « Plus » (a screen of « Plus » beside it), 5 offers (an offer under it),
/// 6 applications.
Future<GoRouter> _pump(WidgetTester tester, {required bool candidate}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  LocaleSettings.setLocaleSync(AppLocale.fr);
  StatefulShellBranch branch(String path, String text,
          {List<RouteBase> routes = const [],
          List<RouteBase> extra = const []}) =>
      StatefulShellBranch(routes: [
        GoRoute(path: path, builder: (_, __) => Text(text), routes: routes),
        ...extra,
      ]);
  final router = GoRouter(
    initialLocation: RouteNames.tutorHome,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => RoleShell(
            navigationShell: shell,
            tabForLocation: (location) =>
                tutorTabOfLocation(location, candidate: candidate),
            tabs: tutorShellTabs(Translations.of(context).shell,
                candidate: candidate)),
        branches: [
          branch(RouteNames.tutorHome, 'home', routes: [
            GoRoute(
                path: 'candidate/file', builder: (_, __) => const Text('file'))
          ]),
          branch(RouteNames.tutorPlanning, 'planning'),
          branch(RouteNames.tutorStudents, 'students'),
          branch(RouteNames.tutorEarnings, 'earnings'),
          branch(RouteNames.tutorMore, 'more', extra: [
            GoRoute(
                path: '/tutor/space/contracts',
                builder: (_, __) => const Text('contracts')),
          ]),
          branch(RouteNames.tutorCandidateOffers, 'offers', routes: [
            GoRoute(path: ':id', builder: (_, __) => const Text('offer')),
          ]),
          branch(RouteNames.tutorCandidateApplications, 'applications'),
        ],
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(
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
  return router;
}

int _selected(WidgetTester tester) =>
    tester.widget<SoeBottomNav>(find.byType(SoeBottomNav)).currentIndex;

void main() {
  testWidgets(
      'a candidate\'s tab bar: Dossier · Offres · Candidatures · Plus (REP-01 « Mode recrutement »)',
      (tester) async {
    final router = await _pump(tester, candidate: true);

    for (final label in ['Dossier', 'Offres', 'Candidatures', 'Plus']) {
      expect(find.byTooltip(label), findsOneWidget);
    }
    expect(find.byTooltip('Planning'), findsNothing);
    expect(find.text('home'), findsOneWidget);
    expect(_selected(tester), 0);

    // The file opens under « Dossier », back returns to the home.
    unawaited(router.push(RouteNames.tutorCandidateFile));
    await tester.pumpAndSettle();
    expect(find.text('file'), findsOneWidget);
    expect(_selected(tester), 0);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);

    // « Offres » is a tab; an offer keeps the tab bar on « Offres » (REP-11).
    await tester.tap(find.byTooltip('Offres'));
    await tester.pumpAndSettle();
    expect(find.text('offers'), findsOneWidget);
    expect(_selected(tester), 1);
    unawaited(router.push('${RouteNames.tutorCandidateOffers}/4'));
    await tester.pumpAndSettle();
    expect(find.text('offer'), findsOneWidget);
    expect(find.byType(SoeBottomNav), findsOneWidget);
    expect(_selected(tester), 1);

    await tester.tap(find.byTooltip('Candidatures'));
    await tester.pumpAndSettle();
    expect(find.text('applications'), findsOneWidget);
    expect(_selected(tester), 2);
  });

  testWidgets(
      'an active tutor: a screen of « Plus » keeps the tab bar on « Plus », back returns to the tab',
      (tester) async {
    final router = await _pump(tester, candidate: false);

    expect(find.byTooltip('Aujourd’hui'), findsOneWidget);
    expect(find.byTooltip('Revenus'), findsOneWidget);
    expect(find.byTooltip('Candidatures'), findsNothing);

    unawaited(router.push('/tutor/space/contracts'));
    await tester.pumpAndSettle();
    expect(find.text('contracts'), findsOneWidget);
    expect(find.byType(SoeBottomNav), findsOneWidget);
    expect(_selected(tester), 4);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(_selected(tester), 0);
  });
}
