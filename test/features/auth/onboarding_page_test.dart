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
import 'package:soe/features/auth/presentation/pages/onboarding_page.dart';
import 'package:soe/i18n/translations.g.dart';

/// AUT-01 in a minimal router: onboarding → role choice / sign-in.
Future<PreferencesStorage> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  AppLocale locale = AppLocale.fr,
  bool launch = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.platformDispatcher.localesTestValue = [locale.flutterLocale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  final prefs = PreferencesStorage(await SharedPreferences.getInstance());
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  LocaleSettings.setLocaleSync(locale);
  final router = GoRouter(
    initialLocation: RouteNames.onboarding,
    routes: [
      GoRoute(
          path: RouteNames.onboarding,
          builder: (_, __) => OnboardingPage(launch: launch)),
      GoRoute(
          path: RouteNames.roleChoice,
          builder: (_, __) => const Text('role-choice')),
      GoRoute(path: RouteNames.login, builder: (_, __) => const Text('login')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [preferencesStorageProvider.overrideWithValue(prefs)],
      child: TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          locale: locale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    ),
  );
  if (!launch) await tester.pumpAndSettle();
  return prefs;
}

void main() {
  testWidgets('shows the first slide with its photo, title and « Suivant »',
      (tester) async {
    await _pump(tester);

    expect(find.text('Un répétiteur choisi pour votre enfant'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('sous le regard de sa mère')),
        findsOneWidget);
    expect(find.text('Suivant'), findsOneWidget);
    expect(find.text('Créer mon compte'), findsNothing);
  });

  testWidgets('« Suivant » goes through the 4 slides', (tester) async {
    await _pump(tester);

    for (final title in [
      'Chaque séance suivie',
      'Un contrat clair, signé en ligne',
      'Payez par Mobile Money'
    ]) {
      await tester.tap(find.text('Suivant'));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('Suivant'), findsNothing);
    expect(find.text('Passer'), findsNothing);
  });

  testWidgets(
      '« Passer » leads to the last slide, « Créer mon compte » ends the welcome',
      (tester) async {
    final prefs = await _pump(tester);

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('role-choice'), findsOneWidget);
    expect(prefs.readBool(StorageKeys.onboardingDoneFlag), isTrue);
  });

  testWidgets('« J’ai déjà un compte » leads to sign-in', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('J’ai déjà un compte'));
    await tester.pumpAndSettle();

    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('the launch screen comes first, then the slides', (tester) async {
    await _pump(tester, launch: true);

    expect(find.bySemanticsLabel('Chargement de SOE'), findsOneWidget);
    expect(find.text('Suivant'), findsNothing);

    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();
    expect(find.text('Un répétiteur choisi pour votre enfant'), findsOneWidget);
    expect(find.text('Répétiteurs vérifiés'), findsOneWidget);
  });

  testWidgets('a phone in English shows the slides in English, no switch',
      (tester) async {
    await _pump(tester, locale: AppLocale.en);

    expect(find.text('A tutor chosen for your child'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('EN'), findsNothing);
    expect(find.text('FR'), findsNothing);
  });

  testWidgets('on a tablet in landscape, the photo sits next to the text',
      (tester) async {
    await _pump(tester, size: const Size(1194, 834));

    expect(find.text('Un répétiteur choisi pour votre enfant'), findsOneWidget);
    expect(find.text('Répétiteurs vérifiés'), findsOneWidget);
    final photo =
        tester.getRect(find.bySemanticsLabel(RegExp('sous le regard')));
    final title =
        tester.getRect(find.text('Un répétiteur choisi pour votre enfant'));
    expect(photo.right, lessThan(title.left));
  });

  testWidgets('on a tablet in portrait, the text sits under the photo',
      (tester) async {
    await _pump(tester, size: const Size(834, 1194));

    final photo =
        tester.getRect(find.bySemanticsLabel(RegExp('sous le regard')));
    final title =
        tester.getRect(find.text('Un répétiteur choisi pour votre enfant'));
    expect(photo.bottom, lessThan(title.top));
  });
}
