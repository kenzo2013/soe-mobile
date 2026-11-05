import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/widgets/soe_button.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_home_page.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';
import 'package:soe/features/tutor_space/presentation/tutor_space_routes.dart';

import '../../helpers/pump_app.dart';
import 'tutor_daily_fakes.dart';

SoeButton _button(WidgetTester tester, String label) =>
    tester.widget<SoeButton>(
        find.byWidgetPredicate((w) => w is SoeButton && w.label == label));

void main() {
  group('REP-01 home', () {
    testWidgets(
        'active: actions by deadline, one gold button, today, the month',
        (tester) async {
      final api = FakeTutorApi(
        homeValue: activeHome(offers: [
          {
            'id': 4,
            'subjects': ['Mathématiques'],
            'school_classes': ['3e'],
            'neighborhood': 'Bonamoussadi',
            'session_rate': 6500,
          }
        ]),
        detailValue: detail(),
      );
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorHomePage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Bonjour Daniel.'), findsOneWidget);
      expect(find.text('À faire'), findsOneWidget);
      expect(find.text('Affectation à confirmer'), findsOneWidget);
      // The most urgent action gets the single gold button; the disputed one is reviewed by SOE.
      expect(_button(tester, 'Voir la proposition').variant,
          SoeButtonVariant.primary);
      expect(_button(tester, 'Voir le PV').variant, SoeButtonVariant.tertiary);
      expect(find.text('SOE examine'), findsOneWidget);
      // Today's session with its place and the parent.
      expect(find.text('Makepe Missoke'), findsOneWidget);
      expect(find.text('Face à la station Total'), findsOneWidget);
      expect(find.text('J’arrive'), findsOneWidget);
      expect(find.text('Itinéraire'), findsOneWidget);
      expect(find.text('Appeler le parent'), findsOneWidget);
      expect(find.text('Ce mois-ci'), findsOneWidget);
      expect(find.text('Offres pour moi'), findsOneWidget);
      expect(find.text('Mathématiques · 3e'), findsOneWidget);
      expect(find.text('Voir toutes les offres'), findsOneWidget);
    });

    testWidgets('recruitment: the next step, what is missing, the journey',
        (tester) async {
      final api = FakeTutorApi(homeValue: recruitmentHome());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorHomePage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Dossier'), findsOneWidget);
      expect(find.text('Ce qui manque'), findsOneWidget);
      expect(
          find.text('Diplômes et justificatifs · à refaire'), findsOneWidget);
      expect(find.text('Compléter mon dossier'), findsOneWidget);
      expect(find.text('Votre parcours'), findsOneWidget);
      expect(find.text('Étape 1 sur 6'), findsOneWidget);
      expect(find.text('Activation du compte'), findsOneWidget);
      expect(find.text('Offres près de chez vous'), findsOneWidget);
      // No fake empty dashboard for a candidate.
      expect(find.text('À faire'), findsNothing);
      expect(find.text('Ce mois-ci'), findsNothing);
    });

    testWidgets(
        'recruitment mode: sections complete, what is missing, the journey, the delay, offers',
        (tester) async {
      final api = FakeTutorApi(homeValue: candidateHome());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorHomePage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(
          find.text('PROCHAINE ÉTAPE · COMPLÉTER LE DOSSIER'), findsOneWidget);
      expect(find.text('5 / 7'), findsOneWidget);
      expect(find.text('sections complètes'), findsOneWidget);
      expect(find.text('Présentation : à compléter.'), findsOneWidget);
      expect(
          find.text(
              'Diplômes et justificatifs : à refaire (relevé illisible).'),
          findsOneWidget);
      expect(find.text('Dossier complet'), findsOneWidget);
      expect(find.text('Délai de validation'), findsOneWidget);
      expect(find.textContaining('sous 5 jours'), findsOneWidget);
      expect(find.text('Offres près de chez vous'), findsOneWidget);
      expect(find.text('Mathématiques · 3e'), findsOneWidget);
      expect(find.textContaining('500'), findsWidgets);
      expect(
          find.text(
              'Vous pouvez postuler avant la validation de votre dossier.'),
          findsOneWidget);
      // The offers come with the home: no other read.
      expect(api.calls, ['home']);
    });

    testWidgets('offline: the last data with « Hors connexion » and retry',
        (tester) async {
      final api = FakeTutorApi(detailValue: detail())
        ..homeFailure = const NetworkFailure();
      useTallView(tester);
      await pumpAppWith(tester, child: const TutorHomePage(), overrides: [
        ...tutorOverrides(api),
        tutorHomeCacheProvider.overrideWith(
            (ref) => (home: activeHome(), at: DateTime(2026, 11, 26, 16, 12))),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Hors connexion · données de 16:12'), findsOneWidget);
      expect(find.text('Disponible au retour du réseau'), findsNWidgets(2));
      expect(find.text('Ce mois-ci'), findsOneWidget);

      api
        ..homeFailure = null
        ..homeValue = activeHome();
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Hors connexion'), findsNothing);
      expect(find.text('Voir la proposition'), findsOneWidget);
    });

    testWidgets('offline without data read before: the error view and retry',
        (tester) async {
      final api = FakeTutorApi()..homeFailure = const NetworkFailure();
      await pumpAppWith(tester,
          child: const TutorHomePage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });

  test('every home action opens its screen', () {
    TutorHomeAction action(String kind) =>
        TutorHomeAction.fromJson({'kind': kind, 'label': '', 'target_id': 7});
    expect(
        tutorActionTarget(action('assignment')), TutorSpaceRoutes.proposal(7));
    expect(tutorActionTarget(action('report')), TutorSpaceRoutes.report(7));
    expect(tutorActionTarget(action('planning')), TutorSpaceRoutes.times(7));
    expect(tutorActionTarget(action('contract')), TutorSpaceRoutes.contract(7));
    expect(tutorActionTarget(action('disputed')), TutorSpaceRoutes.report(7));
  });

  test('each recruitment stage leads to its screen', () {
    expect(tutorRecruitmentTarget('file'), TutorSpaceRoutes.file);
    expect(tutorRecruitmentTarget('documents_check'), TutorSpaceRoutes.file);
    expect(tutorRecruitmentTarget('interview'), TutorSpaceRoutes.interview);
    expect(tutorRecruitmentTarget('charter'), TutorSpaceRoutes.charter);
    expect(tutorRecruitmentTarget('active'), isNull);
  });
}
