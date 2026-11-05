import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/app/app.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/features/auth/presentation/pages/onboarding_page.dart';
import 'package:soe/i18n/translations.g.dart';

Future<PreferencesStorage> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return PreferencesStorage(await SharedPreferences.getInstance());
}

void _setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// The welcome page alone, at a given screen size and system font scale.
Future<void> _pumpPage(WidgetTester tester, Size size, double textScale) async {
  _setScreen(tester, size);
  final prefs = await _prefs();
  LocaleSettings.setLocaleSync(AppLocale.fr);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [preferencesStorageProvider.overrideWithValue(prefs)],
      child: TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppLocaleUtils.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const OnboardingPage(launch: false),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the real app speaks the phone\'s language', (tester) async {
    _setScreen(tester, const Size(390, 844));
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final prefs = await _prefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesStorageProvider.overrideWithValue(prefs)],
        child: const SoeApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('A tutor chosen for your child'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Every session followed'), findsOneWidget);
  });

  testWidgets('an iPhone turned sideways shows the slide without overflow',
      (tester) async {
    await _pumpPage(tester, const Size(844, 390), 1);

    expect(tester.takeException(), isNull);
    expect(find.text('Suivant'), findsOneWidget);
  });

  testWidgets('a small phone with a very large font does not overflow',
      (tester) async {
    await _pumpPage(tester, const Size(320, 568), 2);

    expect(tester.takeException(), isNull);
    expect(find.text('Passer'), findsOneWidget);
  });

  testWidgets(
      'a tablet with a very large font shows the slide without overflow',
      (tester) async {
    await _pumpPage(tester, const Size(834, 1194), 2);

    expect(tester.takeException(), isNull);
    expect(find.text('Répétiteurs vérifiés'), findsOneWidget);
  });
}
