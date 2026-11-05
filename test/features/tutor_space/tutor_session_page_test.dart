import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_session_page.dart';

import '../../helpers/pump_app.dart';
import 'tutor_daily_fakes.dart';

void main() {
  group('REP-17 session', () {
    testWidgets('before the session: check-in, address, session, move, problem',
        (tester) async {
      final api = FakeTutorApi(detailValue: detail());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.textContaining('SÉANCE DU'), findsOneWidget);
      expect(find.text('Mathématiques · Ornella T., Tle D'), findsOneWidget);
      expect(find.text('Pointage'), findsOneWidget);
      expect(find.text('J’arrive'), findsOneWidget);
      expect(find.text('Pas de GPS ou de réseau ? Code de secours'),
          findsOneWidget);
      expect(find.text('Rue 1.234, Makepe Missoke'), findsOneWidget);
      expect(find.text('Itinéraire'), findsOneWidget);
      expect(find.text('Appeler le parent'), findsOneWidget);
      expect(find.textContaining('FCFA si validée'), findsOneWidget);
      expect(find.text('Reporter'), findsOneWidget);
      expect(find.text('Signaler un problème'), findsOneWidget);
    });

    testWidgets('before the contract: the neighbourhood only, no move',
        (tester) async {
      final api =
          FakeTutorApi(detailValue: detail(contact: false, canMove: false));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Makepe Missoke'), findsOneWidget);
      expect(
          find.textContaining('après la signature du contrat'), findsOneWidget);
      expect(find.text('Itinéraire'), findsNothing);
      expect(find.text('Reporter'), findsNothing);
    });

    testWidgets('arrival checked in: the time, « Arrivée vérifiée », Je pars',
        (tester) async {
      final start = DateTime.now().subtract(const Duration(minutes: 5));
      final api = FakeTutorApi(
          detailValue: detail(
              startsAt: start,
              checkedInAt: start.subtract(const Duration(minutes: 2)),
              canMove: false,
              state: 'to_report',
              label: 'En cours'));
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      expect(find.text('Arrivée vérifiée'), findsOneWidget);
      expect(find.text('arrivée pointée · vérifiée par GPS'), findsOneWidget);
      expect(find.text('Je pars'), findsOneWidget);
      expect(find.text('J’arrive'), findsNothing);
    });

    testWidgets('backup code: the notice and the 4-digit code panel',
        (tester) async {
      final api = FakeTutorApi(detailValue: detail());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pas de GPS ou de réseau ? Code de secours'));
      await tester.pumpAndSettle();
      expect(find.text('GPS indisponible ou pas de réseau'), findsOneWidget);
      expect(find.text('Pointer avec le code de secours'), findsOneWidget);
      expect(find.text('Valider le code'), findsOneWidget);
    });

    testWidgets('move: a refusal on the date shows the server message',
        (tester) async {
      final api = FakeTutorApi(detailValue: detail())
        ..actionFailure = const ValidationFailure({
          'date': ['La nouvelle date doit laisser à la famille au moins 24 h.']
        }, 'La nouvelle date doit laisser à la famille au moins 24 h.');
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reporter'));
      await tester.pumpAndSettle();
      expect(find.text('Reporter la séance'), findsOneWidget);
      expect(find.text('La séance garde sa durée : 2 h.'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'Conseil de classe');
      await tester.tap(find.text('Envoyer à la famille'));
      await tester.pumpAndSettle();

      expect(api.moves.single.$3, 'Conseil de classe');
      expect(api.moves.single.$2, matches(RegExp(r'^\d\d:\d\d$')));
      expect(
          find.text(
              'La nouvelle date doit laisser à la famille au moins 24 h.'),
          findsOneWidget);
      expect(find.text('Reporter la séance'), findsOneWidget);
    });

    testWidgets('move: a conflict keeps the sheet with its message',
        (tester) async {
      final api = FakeTutorApi(detailValue: detail())
        ..actionFailure =
            const ConflictFailure('Cette séance ne peut plus être déplacée.');
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reporter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer à la famille'));
      await tester.pumpAndSettle();
      expect(find.text('Cette séance ne peut plus être déplacée.'),
          findsOneWidget);
    });

    testWidgets('move: once moved, the sheet closes and the session refreshes',
        (tester) async {
      final api = FakeTutorApi(detailValue: detail());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reporter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Envoyer à la famille'));
      await tester.pumpAndSettle();
      expect(api.moves, hasLength(1));
      expect(find.text('Reporter la séance'), findsNothing);
      expect(find.text('Séance déplacée. La famille est prévenue.'),
          findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('problem: a subject chip and a message', (tester) async {
      final api = FakeTutorApi(detailValue: detail());
      useTallView(tester);
      await pumpAppWith(tester,
          child: const TutorSessionPage(sessionId: 12),
          overrides: tutorOverrides(api));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Signaler un problème'));
      await tester.pumpAndSettle();
      expect(find.text('Absence de l’élève'), findsOneWidget);
      expect(find.text('Autre'), findsOneWidget);
      expect(find.text('Envoyer'), findsOneWidget);
    });
  });
}
