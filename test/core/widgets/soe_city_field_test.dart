import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/data/cameroon_city.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/providers/cameroon_cities_provider.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/core/widgets/soe_city_field.dart';
import 'package:soe/i18n/translations.g.dart';

final _cities = [
  CameroonCity(name: 'Douala', major: true, region: 'Littoral'),
  CameroonCity(name: 'Yaoundé', major: true, region: 'Centre'),
  CameroonCity(name: "Sa'a"),
];

Future<void> _pump(
    WidgetTester tester, Future<List<CameroonCity>> Function() load,
    {ValueChanged<String>? onChanged, String? value}) async {
  LocaleSettings.setLocaleSync(AppLocale.fr);
  await tester.pumpWidget(ProviderScope(
    overrides: [cameroonCitiesProvider.overrideWith((ref) => load())],
    child: TranslationProvider(
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: AppLocale.fr.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: SoeCityField(
              label: 'Ville', value: value, onChanged: onChanged ?? (_) {}),
        ),
      ),
    ),
  ));
}

Finder get _search => find.widgetWithText(TextField, 'Rechercher une ville');

void main() {
  testWidgets(
      'the sheet lists the main cities first and searches without accents',
      (tester) async {
    String? picked;
    await _pump(tester, () async => _cities,
        onChanged: (city) => picked = city);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Choisissez votre ville'));
    await tester.pumpAndSettle();
    expect(find.text('GRANDES VILLES'), findsOneWidget);
    expect(find.text('AUTRES VILLES DU CAMEROUN'), findsOneWidget);
    expect(find.text('Littoral'), findsOneWidget);

    await tester.enterText(_search, 'YAOUNDE');
    await tester.pump();
    expect(find.text('Douala'), findsNothing);
    expect(find.text('Yaoundé'), findsOneWidget);

    await tester.enterText(_search, 'sa’a'); // iOS smart apostrophe
    await tester.pump();
    expect(find.text("Sa'a"), findsOneWidget);

    await tester.enterText(_search, 'paris');
    await tester.pump();
    expect(find.text('Aucune ville ne correspond.'), findsOneWidget);

    await tester.enterText(_search, 'centre'); // a region
    await tester.pump();
    await tester.tap(find.text('Yaoundé'));
    await tester.pumpAndSettle();
    expect(picked, 'Yaoundé');
  });

  testWidgets('a failed load offers a retry; while it reloads the field waits',
      (tester) async {
    var calls = 0;
    final reload = Completer<List<CameroonCity>>();
    await _pump(tester, () {
      calls += 1;
      return calls == 1 ? Future.error(const NetworkFailure()) : reload.future;
    });
    await tester.pumpAndSettle();
    expect(
        find.text('Liste des villes indisponible. Réessayer'), findsOneWidget);

    await tester.tap(find.text('Liste des villes indisponible. Réessayer'));
    await tester.pump();
    expect(calls, 2);
    expect(find.text('Liste des villes indisponible. Réessayer'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byType(SoeCityField)); // ignored while loading
    await tester.pump();
    expect(calls, 2);

    reload.complete(_cities);
    await tester.pumpAndSettle();
    expect(find.text('Choisissez votre ville'), findsOneWidget);
  });

  testWidgets('screen readers hear the label and the value once',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, () async => _cities, value: 'Douala');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Ville, Douala'), findsOneWidget);
    handle.dispose();
  });
}
