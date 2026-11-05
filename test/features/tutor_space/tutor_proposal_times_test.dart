import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_proposal_page.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_times_page.dart';

import '../../helpers/pump_app.dart';
import 'tutor_daily_fakes.dart';

void main() {
  group('REP-13 proposal', () {
    testWidgets('filled: the pupil, the need, the time left, the pay',
        (tester) async {
      final api = FakeTutorApi(proposalValue: proposalOf());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorProposalPage(proposalId: 3),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Une famille vous est proposée'), findsOneWidget);
      expect(find.text('Samuel, 1re C'), findsOneWidget);
      expect(find.text('Bonapriso'), findsOneWidget);
      expect(find.text('2 séances par semaine · 2 h'), findsOneWidget);
      expect(find.text('Pour répondre'), findsOneWidget);
      expect(find.text('30 h'), findsOneWidget);
      expect(find.text('Rémunération'), findsOneWidget);
      expect(find.text('Accepter la mission'), findsOneWidget);
      expect(find.text('Décliner'), findsOneWidget);
    });

    testWidgets('decline: a reason chip and a detail are sent', (tester) async {
      final api = FakeTutorApi(proposalValue: proposalOf());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorProposalPage(proposalId: 3),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Décliner'));
      await tester.pumpAndSettle();
      expect(find.text('Décliner la proposition'), findsOneWidget);
      await tester.tap(find.text('Créneaux incompatibles'));
      await tester.enterText(
          find.byType(EditableText), 'Je ne suis pas libre le mardi.');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Décliner').last);
      await tester.pumpAndSettle();

      expect(api.answers.single,
          (false, 'Créneaux incompatibles : Je ne suis pas libre le mardi.'));
      expect(find.text('Proposition déclinée'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('expired: the outcome and « Retour »', (tester) async {
      final api = FakeTutorApi(
          proposalValue: proposalOf(status: 'expired', canAnswer: false));
      await pumpAppWith(tester,
          child: const TutorProposalPage(proposalId: 3),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.text('Cette proposition a expiré'), findsOneWidget);
      expect(find.text('Retour'), findsOneWidget);
      expect(find.text('Accepter la mission'), findsNothing);
    });

    testWidgets('accepted: the three next steps', (tester) async {
      final api = FakeTutorApi(
          proposalValue: proposalOf(status: 'accepted', canAnswer: false));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorProposalPage(proposalId: 3),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.text('Mission acceptée'), findsOneWidget);
      expect(find.text('La famille découvre votre fiche'), findsOneWidget);
      expect(find.text('Lettre de mission à signer'), findsOneWidget);
      expect(find.text('Proposer vos créneaux'), findsOneWidget);
    });
  });

  group('REP-15 times', () {
    testWidgets('filled: a day then an hour per session, then send',
        (tester) async {
      final api = FakeTutorApi(planningValue: planning());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorTimesPage(slotId: 5),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Proposer vos créneaux'), findsOneWidget);
      expect(
          find.text('Samuel · 2 séances de 2 h par semaine'), findsOneWidget);
      expect(find.text('Séance 1'), findsOneWidget);
      expect(find.text('Séance 2'), findsOneWidget);

      await tester.tap(find.text('Mardi').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('17:30').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vendredi').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('17:30').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer au parent'));
      await tester.pumpAndSettle();

      expect(api.proposed.single, ['tuesday 17:30', 'friday 17:30']);
    });

    testWidgets('waiting for the parent: the times sent', (tester) async {
      final api = FakeTutorApi(
          planningValue: planning(times: [
        {
          'day': 'tuesday',
          'from': '17:30',
          'to': '19:30',
          'status': 'proposed',
          'status_label': 'Proposé'
        },
        {
          'day': 'friday',
          'from': '17:30',
          'to': '19:30',
          'status': 'proposed',
          'status_label': 'Proposé'
        },
      ]));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorTimesPage(slotId: 5),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('En attente de la famille'), findsOneWidget);
      expect(find.text('Mardi 17:30'), findsOneWidget);
      expect(find.text('Vendredi 17:30'), findsOneWidget);
      expect(find.text('Envoyer au parent'), findsNothing);
    });

    testWidgets('the parent asks for other times: the form again',
        (tester) async {
      final api = FakeTutorApi(
          planningValue: planning(times: [
        {
          'day': 'tuesday',
          'from': '17:30',
          'to': '19:30',
          'status': 'change_requested',
          'status_label': 'À changer'
        },
      ]));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorTimesPage(slotId: 5),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();
      expect(find.text('Le parent demande d’autres créneaux'), findsOneWidget);
      expect(find.text('Envoyer au parent'), findsOneWidget);
    });
  });
}
