import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/theme/app_palette.dart';
import 'package:soe/core/theme/app_spacing.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/core/widgets/soe_bottom_nav.dart';
import 'package:soe/features/common/presentation/widgets/account_ui.dart';
import 'package:soe/features/common/presentation/widgets/space_app_bar.dart';
import 'package:soe/features/common/presentation/widgets/tab_top_bar.dart';
import 'package:soe/features/shell/presentation/widgets/role_shell.dart';
import 'package:soe/i18n/translations.g.dart';

import '../../helpers/fake_api.dart';

const _tabs = [
  ShellTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
  ShellTab(icon: Icons.menu, activeIcon: Icons.menu_open, label: 'More'),
];

/// Cards enough to scroll, the last one keyed.
List<Widget> _cards() => [
      for (var i = 0; i < 12; i++)
        SizedBox(
          key: i == 11 ? const Key('last-card') : null,
          height: 120,
          child: Text('card $i'),
        ),
    ];

/// A pushed screen built as most screens are: a Scaffold and a list padded by
/// [spacePagePadding] with an explicit bottom.
class _PlainPage extends StatelessWidget {
  const _PlainPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppPalette.surfacePage,
        appBar: const SpaceAppBar(title: 'Detail'),
        body: ListView(
          padding: spacePagePadding(context, top: 8, bottom: 32),
          children: _cards(),
        ),
      );
}

/// A list that ends on a sticky bar: the bar, not the list, clears the navigation.
class _StickyPage extends StatelessWidget {
  const _StickyPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(children: [
          Expanded(
            child: ListView(
              padding: spacePagePadding(context, insets: false),
              children: _cards(),
            ),
          ),
          SafeArea(
            top: false,
            child: SizedBox(
                key: const Key('sticky-bar'),
                height: 56,
                child: FilledButton(onPressed: () {}, child: const Text('Go'))),
          ),
        ]),
      );
}

Future<void> _pump(WidgetTester tester, String location) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  // An iPhone's home indicator.
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesStorage(await SharedPreferences.getInstance());
  LocaleSettings.setLocaleSync(AppLocale.fr);
  final router = GoRouter(
    initialLocation: location,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            RoleShell(navigationShell: shell, tabs: _tabs),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const Text('home'),
              routes: [
                GoRoute(path: 'plain', builder: (_, __) => const _PlainPage()),
                GoRoute(
                    path: 'sticky', builder: (_, __) => const _StickyPage()),
                GoRoute(
                    path: 'account',
                    builder: (_, __) =>
                        AccountScaffold(title: 'Account', children: _cards())),
                GoRoute(
                    path: 'screen',
                    builder: (_, __) =>
                        SpaceScreen(title: 'Screen', children: _cards())),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const Text('more'))
          ]),
        ],
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesStorageProvider.overrideWithValue(prefs),
        dioV2Provider.overrideWithValue(FakeApi().dio),
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

/// Scrolls the screen's list to its end.
Future<void> _scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -5000));
  await tester.pumpAndSettle();
}

double _navTop(WidgetTester tester) =>
    tester.getTopLeft(find.byType(SoeBottomNav)).dy;

void main() {
  for (final location in ['/home/plain', '/home/account', '/home/screen']) {
    testWidgets(
        'on $location, the last card scrolls above the floating navigation',
        (tester) async {
      await _pump(tester, location);
      await _scrollToEnd(tester);

      final last = tester.getRect(find.byKey(const Key('last-card')));
      expect(last.bottom, lessThanOrEqualTo(_navTop(tester)));
    });
  }

  testWidgets(
      'a sticky bar clears the navigation, and the list ends right above it',
      (tester) async {
    await _pump(tester, '/home/sticky');
    await _scrollToEnd(tester);

    final bar = tester.getRect(find.byKey(const Key('sticky-bar')));
    expect(bar.bottom, lessThanOrEqualTo(_navTop(tester)));
    final last = tester.getRect(find.byKey(const Key('last-card')));
    expect(last.bottom, lessThanOrEqualTo(bar.top));
    // No room for the navigation left between the list and the bar.
    expect(bar.top - last.bottom, lessThan(SoeBottomNav.clearance));
  });

  testWidgets('spacePagePadding adds the bottom inset unless asked not to',
      (tester) async {
    late EdgeInsets withInsets;
    late EdgeInsets without;
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(
          size: Size(390, 844), padding: EdgeInsets.only(bottom: 134)),
      child: Builder(builder: (context) {
        withInsets = spacePagePadding(context, bottom: 32);
        without = spacePagePadding(context, bottom: 32, insets: false);
        return const SizedBox();
      }),
    ));

    expect(withInsets.bottom, 166);
    expect(without.bottom, 32);
  });
}
