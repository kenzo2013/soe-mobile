import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/parent_space/data/parent_api.dart';
import 'package:soe/features/parent_space/data/parent_flow_models.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_account_pages.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_children_page.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_contract_pages.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_home_page.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_request_detail_page.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_request_wizard_page.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_session_pages.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_tutor_pages.dart';
import 'package:soe/features/parent_space/presentation/providers.dart';
import 'package:soe/features/parent_space/presentation/widgets/parent_more_links.dart';

import '../../helpers/pump_app.dart';

class _MockApi extends Mock implements ParentApi {}

const _home = ParentHome(
  actions: [],
  weekSessions: [],
  requests: [],
  children: [],
  invoice: null,
  advisorName: 'Carine Ekotto',
  advisorPhone: '+237 675 94 23 44',
);

ParentRequestDraft _draft({List<int> childIds = const []}) =>
    ParentRequestDraft.fromJson({
      'child_ids': childIds,
      'complete': false,
      'children': [
        {'id': 3, 'first_name': 'Yann', 'school_class': '4e'},
      ],
      'needs': [
        for (final id in childIds)
          {
            'child_id': id,
            'subject_ids': <int>[],
            'subjects': <String>[],
            'missing': <String>[]
          }
      ],
      'options': {
        'objectives': [
          {'value': 'regular', 'label': 'Suivi régulier'}
        ],
        'moments': [
          {'value': 'sunday', 'label': 'Dimanche'}
        ],
        'genders': [
          {'value': 'no_preference', 'label': 'Indifférent'}
        ],
        'sessions_per_week': [1, 2],
        'session_minutes': [
          {'value': 60, 'label': '1 h'}
        ],
      },
    });

const _references = ParentReferences(
  subjects: [(id: 1, name: 'Mathématiques')],
  schoolClasses: [],
  sections: [],
  cities: [],
);

void main() {
  late _MockApi api;

  setUpAll(() {
    registerFallbackValue(
        const ParentNeed(childId: 0, subjectIds: [], subjects: []));
  });

  setUp(() {
    api = _MockApi();
    when(() => api.home()).thenAnswer((_) async => _home);
  });

  // The test font (Ahem) draws every glyph as a full square, much wider than the app's
  // font: the screens get a tablet-like width so badges and buttons are not cut.
  Future<void> pump(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(600 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpAppWith(tester,
        child: child, overrides: [parentApiProvider.overrideWithValue(api)]);
    await tester.pumpAndSettle();
  }

  testWidgets(
      'PAR-01 shows each card with the texts of the home, without a call per card',
      (tester) async {
    final home = ParentHome.fromJson({
      'actions': <Map<String, dynamic>>[],
      'todo': [
        {
          'kind': 'report',
          'label': 'Procès-verbal à valider',
          'kind_label': 'Procès-verbal à valider',
          'title': 'Léa',
          'deadline':
              DateTime.now().add(const Duration(hours: 46)).toIso8601String(),
          'overdue': false,
          'target_id': 12,
          'heading': 'Anglais · Léa',
          'explanation':
              'Séance du lundi 2 nov. avec Aline N. · validé automatiquement sans réponse.',
          'button_label': 'Examiner le PV',
          'subjects': ['Anglais'],
          'children': ['Léa'],
          'tutor_name': 'Aline N.',
          'hours_left': 46,
          'total_hours': 72,
          'countdown_label': '46 h',
          'deadline_label': 'restantes sur 72 h',
        },
        {
          'kind': 'review',
          'label': 'Avis à donner',
          'title': 'Aline',
          'deadline': null,
          'overdue': false,
          'target_id': 5,
          'heading': 'Comment se passent les cours avec Aline N. ?',
          'explanation':
              'Léa a 4 séances validées. Votre avis aide SOE à suivre la qualité.',
          'button_label': 'Donner mon avis',
        },
      ],
      'week_sessions': <Map<String, dynamic>>[],
      'requests': [
        {
          'id': 52,
          'reference': 'DEM-2610-31',
          'step': 'contract',
          'step_label': 'Contrat à signer',
          'children': ['Yann'],
          'title': 'Maths et physique pour Yann',
          'subjects': ['Maths', 'Physique'],
          'child_labels': ['Yann, 4e'],
          'explanation': 'Après signature, vous payez le premier mois.',
          'quote_valid_until': null,
        }
      ],
      'children': [
        {
          'id': 3,
          'first_name': 'Léa',
          'school_class': 'CM2',
          'courses': [
            {
              'subject': 'Anglais',
              'tutor_name': 'Aline N.',
              'reservation_id': 51
            }
          ],
          'status_label': '1 cours · Anglais',
          'status_tone': 'neutral',
        },
      ],
      'invoice': {
        'id': 1,
        'number': 'INV-1',
        'period': '2026-11-01',
        'amount': 42000,
        'balance_due': 0,
        'status': 'paid',
        'status_label': 'Payé',
        'lines': <Map<String, dynamic>>[],
        'month_label': 'Novembre',
        'summary':
            'Anglais de Léa · payé le 28 oct. par MTN MoMo · reçu disponible.',
        'can_pay': false,
        'receipt_payment_id': 45,
      },
      'advisor': {
        'first_name': 'Carine',
        'last_name': 'Ekotto',
        'phone': '+237675942344',
        'name': 'Carine Ekotto',
        'initials': 'CE',
        'role_label': 'Conseiller SOE',
        'hours_label': 'lun. – sam., 8:00 – 18:00',
        'phone_label': '+237 6 75 94 23 44',
      },
    });
    when(() => api.home()).thenAnswer((_) async => home);
    await pump(tester, const ParentHomePage());

    expect(find.text('Anglais · Léa'), findsOneWidget);
    expect(find.textContaining('Séance du lundi 2 nov.'), findsOneWidget);
    expect(find.text('46 h'), findsOneWidget);
    expect(find.text('restantes sur 72 h'), findsOneWidget);
    expect(find.text('Comment se passent les cours avec Aline N. ?'),
        findsOneWidget);
    expect(find.text('Maths et physique pour Yann'), findsOneWidget);
    expect(find.text('Après signature, vous payez le premier mois.'),
        findsOneWidget);
    expect(find.text('1 cours · Anglais'), findsOneWidget);
    expect(find.text('NOVEMBRE · PAYÉ'), findsOneWidget);
    expect(find.textContaining('par MTN MoMo'), findsOneWidget);
    expect(find.text('Conseiller SOE'), findsOneWidget);
    expect(find.textContaining('+237 6 75 94 23 44'), findsOneWidget);
    // Only the home was read: no request, session, contract or child per card.
    verify(() => api.home()).called(greaterThanOrEqualTo(1));
    verifyNever(() => api.requestDetail(any()));
    verifyNever(() => api.session(any()));
    verifyNever(() => api.contract(any()));
    verifyNever(() => api.child(any()));
  });

  testWidgets('PAR-02 lists the children as cards with « Ajouter un enfant »',
      (tester) async {
    const lea = ParentChild(
        id: 3,
        firstName: 'Léa',
        schoolClass: 'CM2',
        schoolName: 'École de Bonapriso',
        section: 'francophone',
        courses: []);
    when(() => api.children()).thenAnswer((_) async => [lea]);
    when(() => api.child(3)).thenAnswer((_) async => const ParentChild(
            id: 3,
            firstName: 'Léa',
            schoolClass: 'CM2',
            schoolName: null,
            courses: [
              ParentCourse(
                  subject: 'Anglais',
                  tutorName: 'Aline N.',
                  validatedSessions: 8,
                  nextSessionAt: null,
                  stage: 'active'),
            ]));
    await pump(tester, const ParentChildrenPage());

    expect(find.text('Mes enfants'), findsOneWidget);
    expect(find.text('Ajouter un enfant'), findsOneWidget);
    expect(find.text('Léa'), findsOneWidget);
    expect(find.text('CM2 · Francophone · École de Bonapriso'), findsOneWidget);
    expect(find.text('Anglais avec Aline N.'), findsOneWidget);
  });

  testWidgets('PAR-05 saves the chosen children then asks the need',
      (tester) async {
    when(() => api.draftChildren(any()))
        .thenAnswer((_) async => _draft(childIds: [3]));
    await pump(
        tester,
        Scaffold(
            body:
                ParentRequestWizard(draft: _draft(), references: _references)));

    expect(find.text('Pour quel enfant ?'), findsOneWidget);
    await tester.tap(find.text('Yann'));
    await tester.pump();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    verify(() => api.draftChildren([3])).called(1);
    expect(find.text('Le besoin de Yann'), findsOneWidget);
    expect(find.text('Mathématiques'), findsOneWidget);
    expect(find.text('Suivi régulier'), findsOneWidget);
  });

  testWidgets('PAR-05 resumes a started draft at the first incomplete need',
      (tester) async {
    await pump(
        tester,
        Scaffold(
            body: ParentRequestWizard(
                draft: ParentRequestDraft.fromJson({
                  'child_ids': [3],
                  'children': [
                    {'id': 3, 'first_name': 'Yann'}
                  ],
                  'needs': [
                    {
                      'child_id': 3,
                      'subject_ids': <int>[],
                      'missing': ['subject_ids']
                    }
                  ],
                  'options': <String, dynamic>{},
                }),
                references: _references)));

    expect(find.text('Brouillon repris'), findsOneWidget);
    expect(find.text('Le besoin de Yann'), findsOneWidget);
  });

  testWidgets('PAR-07 shows the sections of a request and cancels it',
      (tester) async {
    final detail = ParentRequestDetail.fromJson({
      'id': 7,
      'reference': 'DEM-2610-31',
      'stage': 'quote_sent',
      'step': 'quote',
      'step_label': 'Devis à examiner',
      'children': ['Yann'],
      'action': 'quote',
      'quote_amount': 64000,
      'can_cancel': true,
      'needs': [
        {
          'id': 11,
          'child_id': 3,
          'child': 'Yann',
          'subjects': ['Maths'],
          'sessions_per_week': 2,
          'session_minutes': 120
        }
      ],
      'history': [
        {
          'action': 'reservation.created',
          'label': 'Demande créée',
          'actor': 'you'
        }
      ],
    });
    when(() => api.requestDetail(7)).thenAnswer((_) async => detail);
    when(() => api.cancelRequest(7, any())).thenAnswer((_) async => detail);
    await pump(tester, const ParentRequestDetailPage(requestId: 7));

    expect(find.text('Maths pour Yann'), findsOneWidget);
    expect(find.text('Examiner le devis'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);
    expect(find.text('Demande créée'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Annuler la demande'), 200);
    await tester.tap(find.text('Annuler la demande'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer l’annulation'));
    await tester.pumpAndSettle();
    verify(() => api.cancelRequest(7, '')).called(1);
  });

  testWidgets('PAR-20 requires a reason before asking a replacement',
      (tester) async {
    when(() => api.tutors(7)).thenAnswer((_) async => [
          ParentTutorProfile.fromJson({
            'id': 5,
            'name': 'Aline N.',
            'slots': [
              {'id': 21, 'subject': 'Anglais', 'child': 'Léa'}
            ],
          })
        ]);
    when(() => api.askReplacement(7,
            slotId: any(named: 'slotId'),
            reason: any(named: 'reason'),
            comment: any(named: 'comment')))
        .thenThrow(const ConflictFailure('Déjà demandé.'));
    await pump(tester, const ParentReplacementPage(requestId: 7, slotId: 21));

    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    expect(find.text('Choisissez un motif.'), findsOneWidget);

    await tester.tap(find.text('Ponctualité'));
    await tester.tap(find.text('Envoyer la demande'));
    await tester.pumpAndSettle();
    verify(() => api.askReplacement(7,
        slotId: 21, reason: 'punctuality', comment: '')).called(1);
    expect(find.text('Déjà demandé.'), findsOneWidget);
  });

  testWidgets('PAR-18 sorts the tutors: to give, soon, given', (tester) async {
    when(() => api.reviewTutors()).thenAnswer((_) async => [
          ParentReviewTutor.fromJson({
            'id': 5,
            'name': 'Aline N.',
            'approved_sessions': 8,
            'sessions_required': 4,
            'eligible': true,
            'courses': 'Anglais · Léa'
          }),
          ParentReviewTutor.fromJson({
            'id': 6,
            'name': 'Daniel E.',
            'approved_sessions': 2,
            'sessions_required': 4,
            'eligible': false
          }),
        ]);
    when(() => api.reviews()).thenAnswer((_) async => []);
    await pump(tester, const ParentReviewsPage());

    expect(find.text('À donner'), findsOneWidget);
    expect(find.text('Donner mon avis'), findsOneWidget);
    expect(find.text('Bientôt'), findsOneWidget);
    expect(find.text('2 séances validées sur 4'), findsOneWidget);
    expect(find.text('Aucun avis donné pour l’instant.'), findsOneWidget);
  });

  testWidgets('PAR-19 shows co-parents and pending invitations',
      (tester) async {
    when(() => api.coParents()).thenAnswer((_) async => [
          const ParentCoParent(
              id: 2,
              firstName: 'Paul',
              lastName: 'Mbarga',
              children: ['Léa'],
              canAnswerReports: true)
        ]);
    when(() => api.invitations()).thenAnswer((_) async => [
          ParentInvitation(
              id: 4,
              firstName: 'Brigitte',
              lastName: 'Ngo',
              phone: '+237 699 12 40 31',
              canAnswerReports: false,
              state: 'sent',
              expiresAt: DateTime.now().add(const Duration(days: 4, hours: 1)))
        ]);
    await pump(tester, const ParentCoParentsPage());

    expect(find.text('Paul Mbarga'), findsOneWidget);
    expect(find.text('Modifier les droits'), findsOneWidget);
    expect(find.text('Brigitte Ngo'), findsOneWidget);
    expect(find.text('Renvoyer'), findsOneWidget);
    expect(find.text('Envoyée · expire dans 5 j'), findsOneWidget);
  });

  testWidgets('COM-08 lists contracts with legacy and amendments to sign',
      (tester) async {
    when(() => api.contracts()).thenAnswer((_) async => [
          ParentContract.fromJson({
            'id': 9,
            'reference': 'CTR-9',
            'status': 'sent',
            'status_label': 'Envoyé',
            'legacy': true,
            'amendments_to_sign': 1
          })
        ]);
    await pump(tester, const ParentContractsPage());

    expect(find.text('CTR-9'), findsOneWidget);
    expect(find.text('Ancienne plateforme'), findsOneWidget);
    expect(find.text('1 à signer'), findsOneWidget);
  });

  testWidgets('a contract card is titled by child and subject, status as badge',
      (tester) async {
    when(() => api.contracts()).thenAnswer((_) async => [
          ParentContract.fromJson({
            'id': 9,
            'reference': 'CTR-9',
            'status': 'signed',
            'status_label': 'Signé',
            'children': ['Léa'],
            'subjects': ['Anglais'],
          })
        ]);
    await pump(tester, const ParentContractsPage());

    expect(find.text('Léa · Anglais'), findsOneWidget);
    // « Signé » is the badge only, no longer the card's title.
    expect(find.text('Signé'), findsOneWidget);
  });

  testWidgets('PAR-14 a disputed report shows the parent its own reason',
      (tester) async {
    when(() => api.report(12)).thenAnswer((_) async => ParentReport.fromJson({
          'session_id': 12,
          'child_first_name': 'Léa',
          'topics': ['Les fractions'],
          'validated': false,
          'dispute_reason': 'Le répétiteur est parti 30 min plus tôt.',
          'can_answer': false,
        }));
    await pump(tester, const ParentReportPage(sessionId: 12));

    expect(find.text('Contesté · SOE examine'), findsOneWidget);
    expect(find.byKey(const Key('report-dispute-reason')), findsOneWidget);
    expect(
        find.text('Le répétiteur est parti 30 min plus tôt.'), findsOneWidget);
  });

  testWidgets(
      'PAR-09 a proposed tutor without profile sections has no empty card',
      (tester) async {
    when(() => api.tutors(7)).thenAnswer((_) async => [
          ParentTutorProfile.fromJson({
            'id': 5,
            'name': 'Daniel E.',
            'slots': [
              {'id': 21, 'subject': 'Maths', 'child': 'Yann'}
            ],
            'presentation': '  ',
          })
        ]);
    when(() => api.requestDetail(7)).thenThrow(const NetworkFailure());
    when(() => api.tutorReviews(7, 5)).thenAnswer((_) async => []);
    await pump(tester, const ParentTutorPage(requestId: 7));

    expect(find.text('Daniel E.'), findsOneWidget);
    expect(find.byKey(const Key('tutor-profile-sections')), findsNothing);
    // Not the parent's turn to sign: no « En confirmant, vous signez ».
    expect(find.textContaining('En confirmant'), findsNothing);
  });

  testWidgets('the More entries of the parent', (tester) async {
    await pump(tester, const Scaffold(body: ParentMoreLinks()));
    for (final label in [
      'Demandes et devis',
      'Contrats',
      'Avis',
      'Co-parents',
      'Mon conseiller SOE'
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
