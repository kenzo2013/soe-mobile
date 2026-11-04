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
}) async {
  SharedPreferences.setMockInitialValues(
      {StorageKeys.preferredLang: locale.languageCode});
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
          builder: (_, __) => const OnboardingPage()),
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
  await tester.pumpAndSettle();
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

  testWidgets('the FR / EN switch changes the texts', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('A tutor chosen for your child'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('on a tablet, the brand panel sits next to the slides',
      (tester) async {
    await _pump(tester, size: const Size(834, 1194));

    expect(find.text('Le soutien scolaire à domicile, suivi de bout en bout.'),
        findsOneWidget);
    expect(find.text('Répétiteurs vérifiés'), findsOneWidget);
  });
}
