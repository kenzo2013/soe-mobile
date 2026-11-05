import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor_space/data/tutor_student_models.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_student_pages.dart';
import 'package:soe/features/tutor_space/presentation/tutor_offer_providers.dart';

import '../../helpers/pump_app.dart';

final _pupils = [
  const TutorPupil(
    id: 1,
    pupil: 'Yann M.',
    schoolClass: '4e',
    subjects: const ['Maths et physique'],
    neighborhood: 'Bonapriso',
    state: 'active',
    stateLabel: 'Actif',
    times: const [
      TutorWeeklyTime(day: 'wednesday', from: '16:00', to: '18:00'),
      TutorWeeklyTime(day: 'saturday', from: '09:00', to: '11:00'),
    ],
    startDate: null,
  ),
  TutorPupil(
    id: 2,
    pupil: 'Samuel',
    schoolClass: '1re C',
    subjects: const ['Mathématiques'],
    neighborhood: 'Bonapriso',
    state: 'contract',
    stateLabel: 'Contrat à signer',
    times: const [],
    startDate: DateTime(2026, 12, 7),
  ),
];

TutorPupilFile _file({required bool shared}) => TutorPupilFile(
      id: 1,
      pupil: shared ? 'Yann M.' : 'Samuel',
      schoolClass: shared ? '4e' : '1re C',
      subjects: const ['Mathématiques'],
      times: shared
          ? const [
              TutorWeeklyTime(day: 'wednesday', from: '16:00', to: '18:00')
            ]
          : const [],
      neighborhood: 'Bonapriso',
      contactShared: shared,
      address: shared ? 'Rue Njo-Njo' : null,
      landmark: shared ? 'Portail bleu après la pharmacie' : null,
      parents: shared
          ? const [
              TutorPupilParent(name: 'Mireille Mbarga', phone: '+237677452109')
            ]
          : const [],
      reports: shared
          ? [
              TutorPupilReport(
                  sessionId: 9,
                  date: DateTime(2026, 11, 25),
                  topics: const ['Pythagore', 'lumière'],
                  state: 'report_sent',
                  stateLabel: 'En attente du parent'),
            ]
          : const [],
      slotsToPlan: const [],
    );

void main() {
  testWidgets('REP-14 lists the pupils as a tab', (tester) async {
    await pumpAppWith(
      tester,
      overrides: [tutorStudentsProvider.overrideWith((ref) async => _pupils)],
      child: const TutorStudentsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mes élèves'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Yann M., 4e'), findsOneWidget);
    expect(find.text('YM'), findsOneWidget);
    expect(find.text('Maths et physique · Bonapriso · mer. 16:00, sam. 09:00'),
        findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('Samuel, 1re C'), findsOneWidget);
    expect(find.text('Mathématiques · Bonapriso · début Lun. 7 déc.'),
        findsOneWidget);
    expect(find.text('Contrat à signer'), findsOneWidget);
  });

  testWidgets('REP-14 shows the empty state', (tester) async {
    await pumpAppWith(
      tester,
      overrides: [tutorStudentsProvider.overrideWith((ref) async => [])],
      child: const TutorStudentsPage(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pas encore d’élève'), findsOneWidget);
  });

  testWidgets('REP-14-1 shows the times, the contact and the reports',
      (tester) async {
    await pumpAppWith(
      tester,
      overrides: [
        tutorStudentsProvider.overrideWith((ref) async => _pupils),
        tutorStudentProvider
            .overrideWith((ref, id) async => _file(shared: true)),
      ],
      child: const TutorStudentPage(studentId: 1),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yann M., 4e'), findsOneWidget);
    expect(find.text('Actif'), findsOneWidget);
    expect(find.text('Mercredi'), findsOneWidget);
    expect(find.text('16:00 – 18:00'), findsOneWidget);
    expect(find.text('Rue Njo-Njo'), findsOneWidget);
    expect(find.text('Portail bleu après la pharmacie'), findsOneWidget);
    expect(find.text('Mireille Mbarga · +237677452109'), findsOneWidget);
    expect(find.text('Itinéraire'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pythagore · lumière'), 200);
    expect(find.text('Historique des PV'), findsOneWidget);
    expect(find.text('En attente du parent'), findsOneWidget);
  });

  testWidgets('REP-14-2 hides the address and the parents before the contract',
      (tester) async {
    await pumpAppWith(
      tester,
      overrides: [
        tutorStudentsProvider.overrideWith((ref) async => _pupils),
        tutorStudentProvider
            .overrideWith((ref, id) async => _file(shared: false)),
      ],
      child: const TutorStudentPage(studentId: 2),
    );
    await tester.pumpAndSettle();

    expect(find.text('Samuel, 1re C'), findsOneWidget);
    expect(find.text('Contrat à signer'), findsOneWidget);
    expect(find.text('Adresse et contact'), findsOneWidget);
    expect(find.textContaining('visibles après la signature du contrat'),
        findsOneWidget);
    expect(find.text('À proposer après la signature, dans vos disponibilités.'),
        findsOneWidget);
    expect(find.text('Appeler'), findsNothing);
    expect(find.text('Itinéraire'), findsNothing);
  });
}
