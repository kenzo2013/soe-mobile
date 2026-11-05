import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/widgets/soe_signature.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_planning_page.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_report_page.dart';

import '../../helpers/pump_app.dart';
import 'tutor_daily_fakes.dart';

void main() {
  group('REP-16 planning', () {
    testWidgets('week: filters, the days, the sessions and the legend',
        (tester) async {
      final api = FakeTutorApi(sessionsValue: [
        session(),
        session(
            id: 13,
            startsAt: DateTime.now().add(const Duration(days: 1)),
            state: 'approved',
            label: 'Validée'),
      ]);
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorPlanningPage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Vos séances à domicile.'), findsOneWidget);
      for (final filter in [
        'Toutes',
        'À venir',
        'PV à rédiger',
        'Contestées',
        'Suspendues'
      ]) {
        expect(find.text(filter), findsWidgets);
      }
      expect(find.textContaining('Semaine du'), findsOneWidget);
      expect(find.text('Semaine'), findsOneWidget);
      expect(find.text('Mois'), findsOneWidget);
      expect(find.text('Mathématiques · Ornella T., Tle D'), findsNWidgets(2));
      expect(find.text('Prévue'), findsWidgets);
      expect(find.text('Validée'), findsNWidgets(2)); // badge and legend
      expect(api.filters.last, isNull);
    });

    testWidgets('the « Contestées » filter asks the API and explains',
        (tester) async {
      final api = FakeTutorApi(sessionsValue: [
        session(state: 'disputed', label: 'Contestée · SOE examine')
      ]);
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorPlanningPage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contestées'));
      await tester.pumpAndSettle();
      expect(api.filters.last, 'disputed');
      expect(find.text('Contestée · SOE examine'), findsOneWidget);
      expect(find.textContaining('retirée de vos revenus'), findsOneWidget);
    });

    testWidgets('empty: no session in the period', (tester) async {
      final api = FakeTutorApi();
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorPlanningPage(), overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.text('Aucune séance sur cette période'), findsOneWidget);

      await tester.tap(find.text('Mois'));
      await tester.pumpAndSettle();
      expect(find.text('Aucune séance sur cette période'), findsOneWidget);
    });
  });

  group('REP-18 report', () {
    testWidgets('not yet available: when it opens, when it is due',
        (tester) async {
      final start = DateTime.now().subtract(const Duration(minutes: 2));
      final api = FakeTutorApi(
          detailValue: detail(
              startsAt: start,
              checkedInAt: start,
              reportAvailableAt: start.add(const Duration(minutes: 10))));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorReportPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.textContaining('Le PV sera disponible à'), findsOneWidget);
      expect(find.text('ouverture'), findsOneWidget);
      expect(find.text('à rendre au plus tard'), findsOneWidget);
    });

    testWidgets('entry: the check-in times, then one question per screen',
        (tester) async {
      final start = DateTime.now().subtract(const Duration(hours: 2));
      final api = FakeTutorApi(
          detailValue: detail(
              startsAt: start,
              checkedInAt: start,
              checkedOutAt: start.add(const Duration(hours: 2))));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorReportPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Horaires effectifs'), findsOneWidget);
      expect(find.text('Corriger les horaires'), findsOneWidget);
      expect(find.text('Question 1 sur 5'), findsOneWidget);
      expect(find.text('Qu’avez-vous travaillé ?'), findsOneWidget);

      // Correct the times: a reason is required.
      await tester.tap(find.text('Corriger les horaires'));
      await tester.pumpAndSettle();
      expect(find.text('Indiquez un motif pour corriger les horaires.'),
          findsOneWidget);
      await tester.enterText(find.byType(EditableText).last, 'Portail fermé');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enregistrer la correction'));
      await tester.pumpAndSettle();
      expect(find.text('Corrigés'), findsOneWidget);
      expect(find.text('« Portail fermé »'), findsOneWidget);
    });

    testWidgets('network cut: the draft is kept and sent again',
        (tester) async {
      final start = DateTime.now().subtract(const Duration(hours: 2));
      final api = FakeTutorApi(
          detailValue: detail(
              startsAt: start,
              checkedInAt: start,
              checkedOutAt: start.add(const Duration(hours: 2))),
          reportValue: null)
        ..actionFailure = const NetworkFailure();
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorReportPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'Pythagore');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ajouter'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Suivant'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Signez le PV'), findsOneWidget);
      await tester.drag(find.byType(SoeSignaturePad), const Offset(80, 20));
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(find.text('Signer et envoyer'));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pumpAndSettle();
      expect(api.calls.where((c) => c == 'sendReport'), hasLength(1));
      expect(
          find.text(
              'Réseau coupé : votre brouillon est gardé sur ce téléphone'),
          findsOneWidget);
      final container = ProviderScope.containerOf(
          tester.element(find.byType(TutorReportPage)));
      final draft = container.read(tutorReportDraftsProvider)[12]!;
      expect(draft.topics, ['Pythagore']);
      expect(draft.step, 4);
      expect(draft.signature, isNotEmpty);
    });

    testWidgets('disputed: the parent reason, the times, the follow-up',
        (tester) async {
      final start = DateTime(2026, 11, 21, 9, 28);
      final api = FakeTutorApi(
          detailValue: detail(
              startsAt: DateTime(2026, 11, 21, 9),
              checkedInAt: start,
              checkedOutAt: DateTime(2026, 11, 21, 11, 2),
              canMove: false,
              state: 'disputed',
              label: 'Contestée',
              hasReport: true),
          reportValue:
              report(validated: false, disputeReason: 'Horaires inexacts'));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorReportPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('PV du samedi 21 novembre'), findsOneWidget);
      expect(find.text('Contesté · SOE examine'), findsOneWidget);
      expect(
          find.text('Motif du parent : « Horaires inexacts »'), findsOneWidget);
      expect(find.text('Horaires du PV'), findsOneWidget);
      expect(find.text('Corrigés'), findsOneWidget);
      expect(find.text('09:00 → 11:00'), findsOneWidget);
      expect(find.text('Votre PV'), findsOneWidget);
      expect(find.text('Suivi'), findsOneWidget);
      expect(find.text('Décision de SOE'), findsOneWidget);
      expect(find.text('Pendant l’examen'), findsOneWidget);
    });

    testWidgets('validated: the pay of the session and « Voir mes revenus »',
        (tester) async {
      final api = FakeTutorApi(
          detailValue: detail(
              startsAt: DateTime(2026, 11, 21, 9),
              checkedInAt: DateTime(2026, 11, 21, 9),
              hasReport: true),
          reportValue: report(validated: true));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorReportPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.text('PV validé par le parent'), findsOneWidget);
      expect(find.textContaining('+ 6'), findsOneWidget);
      expect(find.text('Voir mes revenus'), findsOneWidget);
    });
  });
}
