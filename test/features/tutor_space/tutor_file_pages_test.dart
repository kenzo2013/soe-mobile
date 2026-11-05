import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/core/widgets/soe_button.dart';
import 'package:soe/features/tutor_space/data/tutor_file_api.dart';
import 'package:soe/features/tutor_space/data/tutor_file_models.dart';
import 'package:soe/features/tutor_space/data/tutor_references.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_charter_page.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_file_pages.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_interview_page.dart';
import 'package:soe/features/tutor_space/presentation/tutor_file_providers.dart';
import 'package:soe/i18n/translations.g.dart';

import 'tutor_file_fixtures.dart';

/// Answers from canned payloads and records the calls.
class _FakeApi extends TutorFileApi {
  _FakeApi({
    Map<String, dynamic>? file,
    this.sections = const {},
    this.interviewJson,
    this.charterJson,
  })  : fileData = file ?? fileJson(),
        super(Dio());

  final Map<String, dynamic> fileData;
  final Map<String, Map<String, dynamic>> sections;
  final Map<String, dynamic>? interviewJson;
  final Map<String, dynamic>? charterJson;
  final List<String> calls = [];
  Map<String, Object?>? lastFields;

  @override
  Future<TutorFile> file() async => TutorFile.fromJson(fileData);

  @override
  Future<TutorFile> submit() async {
    calls.add('submit');
    return TutorFile.fromJson(fileData);
  }

  @override
  Future<TutorFileSection> section(String section) async =>
      TutorFileSection.fromJson(sections[section]!);

  @override
  Future<TutorFileSection> updateSection(
      String section, Map<String, Object?> fields,
      {List<TutorUpload> files = const [], String? filesField}) async {
    calls.add('update $section');
    lastFields = fields;
    return TutorFileSection.fromJson(sections[section]!);
  }

  @override
  Future<TutorFileSection> deleteItem(String section, int itemId) async {
    calls.add('delete $section $itemId');
    return TutorFileSection.fromJson(sections[section]!);
  }

  @override
  Future<TutorInterview> interview() async =>
      TutorInterview.fromJson(interviewJson!);

  @override
  Future<TutorCharter> charter() async => TutorCharter.fromJson(charterJson!);

  @override
  Future<TutorCharter> signCharter(List<int> png) async {
    calls.add('sign ${png.isNotEmpty}');
    return TutorCharter.fromJson(charterJson!);
  }
}

/// Pumps [child] at `/start` with the recruitment routes it opens (each shows its path).
Future<void> _pump(WidgetTester tester, Widget child, _FakeApi api) async {
  // Wide: the test font draws every glyph as a square, far wider than the real one.
  tester.view.physicalSize = const Size(900 * 3, 1600 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  LocaleSettings.setLocaleSync(AppLocale.fr);
  Widget path(BuildContext context, GoRouterState state) =>
      Scaffold(body: Text('route ${state.uri.path}'));
  final router = GoRouter(initialLocation: '/start', routes: [
    GoRoute(path: '/start', builder: (context, state) => child),
    GoRoute(path: '/tutor/space/file', builder: path),
    GoRoute(path: '/tutor/space/file/:section', builder: path),
    GoRoute(path: '/tutor/space/interview', builder: path),
    GoRoute(path: '/tutor/space/charter', builder: path),
    GoRoute(path: '/tutor/space/offers', builder: path),
  ]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      tutorFileApiProvider.overrideWithValue(api),
      tutorReferencesProvider.overrideWith((ref) async => const TutorReferences(
            subjects: [TutorReference(id: 1, name: 'Mathématiques')],
            schoolClasses: [TutorReference(id: 7, name: '4e')],
            cities: [
              TutorCity(name: 'Douala', neighborhoods: ['Makepe', 'Akwa'])
            ],
          )),
    ],
    child: TranslationProvider(
      child: MaterialApp.router(
        theme: AppTheme.light(),
        locale: AppLocale.fr.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: router,
      ),
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _tapButton(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('REP-02 file', () {
    testWidgets('being filled: progress, document to redo, badge, journey',
        (tester) async {
      await _pump(tester, const TutorFilePage(), _FakeApi());
      expect(find.text('À compléter'), findsOneWidget);
      expect(find.textContaining('5 sections sur 7 complètes'), findsOneWidget);
      expect(find.text('1 pièce à refaire'), findsOneWidget);
      expect(find.text('Diplômes et justificatifs : Relevé illisible.'),
          findsOneWidget);
      expect(find.text('Ce que verra le parent'), findsOneWidget);
      expect(find.text('Étape 1 sur 6'), findsOneWidget);
      // No submit while a section is missing.
      expect(find.text('Envoyer mon dossier'), findsNothing);

      await _tapButton(tester, 'Refaire');
      expect(find.text('route /tutor/space/file/diplomas'), findsOneWidget);
    });

    testWidgets('complete: sent to SOE', (tester) async {
      final api = _FakeApi(
          file: fileJson(
              canSubmit: true,
              presentation: 'in_review',
              diplomas: 'in_review'));
      await _pump(tester, const TutorFilePage(), api);
      await _tapButton(tester, 'Envoyer mon dossier');
      expect(api.calls, ['submit']);
      expect(find.text('Dossier envoyé : SOE vérifie vos pièces.'),
          findsOneWidget);
    });

    testWidgets('at the interview: under review, link to the interview',
        (tester) async {
      await _pump(
          tester,
          const TutorFilePage(),
          _FakeApi(
              file:
                  fileJson(stage: 'interview', step: 3, diplomas: 'accepted')));
      expect(find.text('En vérification'), findsWidgets);
      await _tapButton(tester, 'Voir l’entretien et le test');
      expect(find.text('route /tutor/space/interview'), findsOneWidget);
    });
  });

  group('REP-03 to REP-09 sections', () {
    testWidgets('identity to redo: refused photo, save blocked',
        (tester) async {
      final api = _FakeApi(sections: {
        'identity': sectionJson('identity',
            state: 'redo',
            redoReason: 'Photo floue et reflets sur la carte.',
            content: {
              'document_type': 'cni',
              'birthdate': '1996-04-12',
              'expires_on': '2030-01-01',
              'images_count': 2,
            }),
      });
      await _pump(tester, const TutorFileSectionPage(section: 'identity'), api);
      expect(find.text('Section 1 sur 7'), findsOneWidget);
      expect(find.text('Photo refusée'), findsNWidgets(2));
      expect(find.text('Reprenez la photo de la pièce pour continuer.'),
          findsOneWidget);
      final button = tester.widget<SoeButton>(
          find.widgetWithText(SoeButton, 'Enregistrer et continuer'));
      expect(button.onPressed, isNull);
    });

    testWidgets('identity to provide: the guided frame', (tester) async {
      await _pump(
          tester,
          const TutorFileSectionPage(section: 'identity'),
          _FakeApi(sections: {
            'identity': sectionJson('identity', content: {
              'document_type': null,
              'birthdate': null,
              'expires_on': null,
              'images_count': 0,
            }),
          }));
      expect(find.text('Placez la carte dans le cadre'), findsNWidgets(2));
      expect(find.text('Prendre la photo'), findsNWidgets(2));
    });

    testWidgets('a checked document cannot change', (tester) async {
      await _pump(
          tester,
          const TutorFileSectionPage(section: 'identity'),
          _FakeApi(sections: {
            'identity': sectionJson('identity',
                state: 'accepted',
                editable: false,
                content: {
                  'document_type': 'cni',
                  'birthdate': '1996-04-12',
                  'expires_on': '2030-01-01',
                  'images_count': 2,
                }),
          }));
      expect(find.text('Pièce vérifiée'), findsOneWidget);
      expect(find.text('Reprendre'), findsNothing);
      await _tapButton(tester, 'Continuer');
      expect(find.text('route /tutor/space/file/address'), findsOneWidget);
    });

    testWidgets('availability: a tapped block is saved, then the next section',
        (tester) async {
      final api = _FakeApi(sections: {
        'availability': sectionJson('availability', content: {
          'days': <dynamic>[],
          'opens_at': '07:00',
          'closes_at': '21:30',
        }),
      });
      await _pump(
          tester, const TutorFileSectionPage(section: 'availability'), api);
      expect(find.text('Choisissez au moins une plage.'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(RegExp('^Lundi 16:00')));
      await tester.pumpAndSettle();
      expect(find.text('1 plage'), findsOneWidget);
      await _tapButton(tester, 'Enregistrer et continuer');
      expect(api.calls, ['update availability']);
      final days = api.lastFields!['days']! as Map<String, Object?>;
      expect(days['monday'], [
        {'from': '16:00', 'to': '21:30'}
      ]);
      expect(find.text('route /tutor/space/file/diplomas'), findsOneWidget);
    });

    testWidgets('subjects: the classes and their subjects, removed',
        (tester) async {
      final api = _FakeApi(sections: {
        'subjects': sectionJson('subjects', state: 'complete', content: {
          'items': [
            {
              'id': 5,
              'school_class_id': 7,
              'school_class': '4e',
              'subject_ids': [1],
              'subjects': ['Mathématiques'],
            }
          ],
        }),
      });
      await _pump(tester, const TutorFileSectionPage(section: 'subjects'), api);
      expect(find.text('4e'), findsOneWidget);
      expect(find.text('1 matière · 1 classe'), findsOneWidget);
      await tester.tap(find.byTooltip('Retirer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Retirer').last);
      await tester.pumpAndSettle();
      expect(api.calls, ['delete subjects 5']);
    });

    testWidgets('experiences: empty, continue without', (tester) async {
      await _pump(
          tester,
          const TutorFileSectionPage(section: 'experiences'),
          _FakeApi(sections: {
            'experiences':
                sectionJson('experiences', content: {'items': <dynamic>[]}),
          }));
      expect(find.text('Aucune expérience pour l’instant'), findsOneWidget);
      expect(find.text('Continuer sans expérience'), findsOneWidget);
      expect(
          find.text(
              'Une expérience au moins est nécessaire pour envoyer le dossier.'),
          findsOneWidget);
    });

    testWidgets('presentation: text too long blocks the save', (tester) async {
      await _pump(
          tester,
          const TutorFileSectionPage(section: 'presentation'),
          _FakeApi(sections: {
            'presentation': sectionJson('presentation',
                content: {'bio': 'Bonjour', 'bio_max': 20, 'has_photo': true}),
          }));
      expect(find.text('7 / 20'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'x' * 25);
      await tester.pumpAndSettle();
      expect(
          find.text(
              'Votre texte dépasse 20 caractères : raccourcissez-le de 5 caractères.'),
          findsOneWidget);
      expect(find.text('Raccourcissez votre texte pour continuer.'),
          findsOneWidget);
    });

    testWidgets('presentation, the last section: saves and sends the file',
        (tester) async {
      final api = _FakeApi(file: fileJson(diplomas: 'in_review'), sections: {
        'presentation': sectionJson('presentation',
            content: {'bio': 'Bonjour', 'bio_max': 500, 'has_photo': true}),
      });
      await _pump(
          tester, const TutorFileSectionPage(section: 'presentation'), api);
      await tester.enterText(find.byType(TextFormField), 'Bonjour à tous');
      await tester.pumpAndSettle();
      await _tapButton(tester, 'Enregistrer et envoyer mon dossier');
      expect(api.calls, ['update presentation', 'submit']);
    });

    testWidgets('an unknown section', (tester) async {
      await _pump(
          tester, const TutorFileSectionPage(section: 'nope'), _FakeApi());
      expect(find.text('Cette section n’existe pas.'), findsOneWidget);
    });
  });

  group('REP-23 interview', () {
    Map<String, dynamic> interview(String stage,
            {String? at, int? score, bool passed = false}) =>
        {
          'stage': stage,
          'interview_at': at,
          'interview_passed': passed,
          'bring': ['Votre pièce d’identité originale.'],
          'test_score': score,
          'test_passed': stage == 'charter',
        };

    testWidgets('no date yet', (tester) async {
      await _pump(tester, const TutorInterviewPage(),
          _FakeApi(interviewJson: interview('interview')));
      expect(
          find.text(
              'L’équipe de recrutement SOE vous propose bientôt un créneau d’entretien.'),
          findsOneWidget);
      expect(find.text('Votre pièce d’identité originale.'), findsOneWidget);
      expect(find.text('Le test de niveau a lieu après l’entretien.'),
          findsOneWidget);
    });

    testWidgets('date set by SOE', (tester) async {
      await _pump(
          tester,
          const TutorInterviewPage(),
          _FakeApi(
              interviewJson:
                  interview('interview', at: '2026-12-02T11:00:00+01:00')));
      expect(find.text('Entretien prévu'), findsOneWidget);
      expect(find.textContaining('à '), findsWidgets);
    });

    testWidgets('test passed: the score and the charter next', (tester) async {
      await _pump(
          tester,
          const TutorInterviewPage(),
          _FakeApi(
              interviewJson: interview('charter',
                  at: '2026-12-02T11:00:00+01:00', score: 82, passed: true)));
      expect(find.text('Résultat : 82 / 100'), findsOneWidget);
      expect(find.text('Réussi'), findsNWidgets(2));
      await _tapButton(tester, 'Lire la charte');
      expect(find.text('route /tutor/space/charter'), findsOneWidget);
    });
  });

  group('REP-24 charter', () {
    testWidgets('read, signed with the finger, success', (tester) async {
      final api = _FakeApi(charterJson: charterJson(canSign: true));
      await _pump(tester, const TutorCharterPage(), api);
      expect(find.text('À signer'), findsOneWidget);
      expect(find.text('1. Ponctualité et présence'), findsOneWidget);
      // The short charter fits on the screen: read in full, the pad shows.
      expect(find.text('Lue en entier'), findsOneWidget);
      expect(find.text('Votre signature'), findsOneWidget);
      final pad = find.byType(CustomPaint).last;
      await tester.ensureVisible(pad);
      await tester.dragFrom(
          tester.getCenter(find.text('Votre signature')) + const Offset(0, 80),
          const Offset(120, 20));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Signer la charte'));
      // The PNG is drawn by the engine, outside the fake clock.
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
      expect(api.calls, ['sign true']);
      expect(find.text('Charte signée'), findsWidgets);
      expect(find.text('Voir les offres'), findsOneWidget);
    });

    testWidgets('signed: the date, no signature', (tester) async {
      await _pump(
          tester,
          const TutorCharterPage(),
          _FakeApi(
              charterJson: charterJson(
                  canSign: false, signedAt: '2026-12-04T17:20:00+01:00')));
      expect(find.text('Signée'), findsOneWidget);
      expect(find.textContaining('Signée le'), findsOneWidget);
      expect(find.text('Signer la charte'), findsNothing);
    });

    testWidgets('before the charter stage', (tester) async {
      await _pump(tester, const TutorCharterPage(),
          _FakeApi(charterJson: charterJson(canSign: false, stage: 'test')));
      expect(find.text('La charte se signe après le test de niveau.'),
          findsOneWidget);
    });
  });
}
