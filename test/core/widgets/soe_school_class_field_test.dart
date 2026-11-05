import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/data/school_catalog.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/core/widgets/soe_school_class_field.dart';
import 'package:soe/i18n/translations.g.dart';

const _catalog = SchoolCatalog(subjects: [], classes: [
  SchoolClassRef(
      id: 1,
      name: 'Sixième (6e)',
      abbr: '6e',
      subsystem: 'francophone',
      track: 'general',
      cycle: 'lower_secondary'),
  SchoolClassRef(
      id: 2,
      name: 'Terminale C',
      abbr: 'Tle C',
      subsystem: 'francophone',
      track: 'general',
      cycle: 'upper_secondary'),
  SchoolClassRef(
      id: 3,
      name: 'Troisième Latin',
      subsystem: 'francophone',
      track: 'general',
      cycle: 'lower_secondary',
      active: false),
  SchoolClassRef(
      id: 4,
      name: 'Form 1',
      nameEn: 'Form 1',
      subsystem: 'anglophone',
      track: 'general',
      cycle: 'lower_secondary'),
  SchoolClassRef(
      id: 5,
      name: 'Seconde F3',
      subsystem: 'francophone',
      track: 'technic',
      cycle: 'upper_secondary'),
]);

Future<void> _pump(WidgetTester tester,
    {AppLocale locale = AppLocale.fr,
    int? value,
    String? subsystem,
    ValueChanged<int>? onChanged}) async {
  LocaleSettings.setLocaleSync(locale);
  await tester.pumpWidget(TranslationProvider(
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(
        body: SoeSchoolClassField(
            catalog: _catalog,
            value: value,
            subsystem: subsystem,
            onChanged: onChanged ?? (_) {}),
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'groups the active classes of the sub-system by cycle, technical apart, and searches',
      (tester) async {
    int? picked;
    await _pump(tester,
        subsystem: 'francophone', onChanged: (id) => picked = id);

    await tester.tap(find.text('Choisir la classe'));
    await tester.pumpAndSettle();
    expect(find.text('COLLÈGE · FRANCOPHONE'), findsOneWidget);
    expect(find.text('LYCÉE · FRANCOPHONE'), findsOneWidget);
    expect(find.text('ENSEIGNEMENT TECHNIQUE · FRANCOPHONE'), findsOneWidget);
    expect(find.text('Troisième Latin'), findsNothing,
        reason: 'inactive, not chosen');
    expect(find.text('Form 1'), findsNothing, reason: 'other sub-system');

    await tester.enterText(
        find.widgetWithText(TextField, 'Rechercher une classe'), 'tle c');
    await tester.pump();
    expect(find.text('Sixième (6e)'), findsNothing);
    await tester.tap(find.text('Terminale C'));
    await tester.pumpAndSettle();
    expect(picked, 2);
  });

  testWidgets('keeps an inactive class already chosen', (tester) async {
    await _pump(tester, subsystem: 'francophone', value: 3);
    expect(find.text('Troisième Latin'), findsOneWidget);
    await tester.tap(find.text('Troisième Latin'));
    await tester.pumpAndSettle();
    expect(find.text('Troisième Latin'), findsNWidgets(2));
  });

  testWidgets('speaks English when the app does', (tester) async {
    await _pump(tester, locale: AppLocale.en, subsystem: 'anglophone');
    await tester.tap(find.text('Choose the class'));
    await tester.pumpAndSettle();
    expect(find.text('SECONDARY (LOWER) · ENGLISH-SPEAKING'), findsOneWidget);
    expect(find.text('Form 1'), findsOneWidget);
  });
}
