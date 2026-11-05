import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/network/paginated.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';
import 'package:soe/features/tutor_space/data/tutor_offer_api.dart';
import 'package:soe/features/tutor_space/data/tutor_offer_models.dart';
import 'package:soe/features/tutor_space/data/tutor_references.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_offer_pages.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';
import 'package:soe/features/tutor_space/presentation/tutor_offer_providers.dart';

import '../../helpers/pump_app.dart';
import 'tutor_daily_fakes.dart';

TutorOffer _offer(int id,
        {bool applied = false,
        String reference = 'OFF-2611-07',
        DateTime? startDate,
        String? startLabel,
        bool startPassed = false}) =>
    TutorOffer(
      id: id,
      reference: reference,
      subjects: const ['Mathématiques', 'Physique'],
      schoolClasses: const ['3e'],
      neighborhood: 'Bonamoussadi',
      description: 'Élève de 3e, préparation du BEPC.',
      startDate: startDate ?? DateTime(2026, 11, 16),
      startLabel: startLabel,
      startPassed: startPassed,
      sessionRate: 6500,
      publishedAt: DateTime(2026, 11, 2),
      applied: applied,
      applicationStatus: applied ? 'sent' : null,
      appliedAt: applied ? DateTime(2026, 11, 24) : null,
      canApply: !applied,
    );

Paginated<TutorOffer> _page(List<TutorOffer> items,
        {int page = 1, int totalPages = 1, int? total}) =>
    Paginated(
        items: items,
        page: page,
        perPage: 20,
        totalCount: total ?? items.length,
        totalPages: totalPages);

/// Records the calls of the offer screens.
class _FakeApi extends TutorOfferApi {
  _FakeApi({this.failure}) : super(Dio());

  final Failure? failure;
  final applied = <(int, String?)>[];

  @override
  Future<TutorOffer> offer(int id) async => _offer(id);

  @override
  Future<TutorApplication> apply(int id, {String? message}) async {
    if (failure != null) throw failure!;
    applied.add((id, message));
    return TutorApplication(
        id: 1,
        status: 'sent',
        statusLabel: 'Envoyée',
        sentAt: DateTime(2026, 11, 24),
        message: message,
        offerId: id,
        reference: 'OFF-2611-07',
        subjects: const ['Mathématiques'],
        schoolClass: '3e',
        neighborhood: 'Bonamoussadi');
  }
}

const _references = TutorReferences(
  subjects: [],
  schoolClasses: [TutorReference(id: 4, name: 'Tle D')],
  cities: [],
);

void main() {
  group('REP-10 offers', () {
    testWidgets('lists the offers with the filters and loads more',
        (tester) async {
      final asked = <TutorOfferPageKey>[];
      await pumpAppWith(
        tester,
        overrides: [
          tutorReferencesProvider.overrideWith((ref) async => _references),
          tutorOffersPageProvider.overrideWith((ref, key) async {
            asked.add(key);
            return key.page == 1
                ? _page([_offer(1, applied: true)], totalPages: 2, total: 2)
                : _page([_offer(2, reference: 'OFF-2611-11')],
                    page: 2, totalPages: 2, total: 2);
          }),
        ],
        child: const TutorOffersPage(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Offres'), findsOneWidget);
      expect(find.text('2 offres'), findsOneWidget);
      expect(find.text('OFF-2611-07 · Bonamoussadi'), findsOneWidget);
      expect(find.text('Mathématiques et Physique · 3e'), findsOneWidget);
      expect(find.textContaining(RegExp(r'^6\s500$')), findsOneWidget);
      expect(find.text('Postulé'), findsOneWidget);
      expect(asked.single.filters, const TutorOfferFilters());

      // The whole tab is built at once (the cards overlap the band): bring the button in.
      await tester.ensureVisible(find.text('Voir plus d’offres'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voir plus d’offres'));
      await tester.pumpAndSettle();
      expect(find.text('OFF-2611-11 · Bonamoussadi'), findsOneWidget);
      expect(find.text('Voir plus d’offres'), findsNothing);

      await tester.scrollUntilVisible(find.text('Ma ville'), -200);
      await tester.tap(find.text('Ma ville'));
      await tester.pumpAndSettle();
      expect(asked.last,
          const TutorOfferPageKey(TutorOfferFilters(zone: false), 1));

      await tester.tap(find.text('Classe'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tle D'));
      await tester.pumpAndSettle();
      expect(asked.last.filters.schoolClassId, 4);
      expect(find.text('Tle D'), findsOneWidget);
    });

    Future<void> pumpOffers(WidgetTester tester, TutorHome? home,
            {List<TutorOffer>? offers}) =>
        pumpAppWith(
          tester,
          overrides: [
            tutorReferencesProvider.overrideWith((ref) async => _references),
            tutorOffersPageProvider
                .overrideWith((ref, key) async => _page(offers ?? [_offer(1)])),
            tutorHomeCacheProvider.overrideWith((ref) =>
                home == null ? null : (home: home, at: DateTime.now())),
          ],
          child: const TutorOffersPage(),
        );

    const note = 'Vous pouvez postuler avant la validation de votre dossier.';

    testWidgets('the note of the server for a candidate', (tester) async {
      await pumpOffers(tester, candidateHome());
      await tester.pumpAndSettle();
      expect(find.text(note), findsOneWidget);
    });

    testWidgets('our note for a candidate when the server sends none',
        (tester) async {
      await pumpOffers(tester, recruitmentHome());
      await tester.pumpAndSettle();
      expect(find.text(note), findsOneWidget);
    });

    testWidgets('no note for an active tutor', (tester) async {
      await pumpOffers(tester, activeHome());
      await tester.pumpAndSettle();
      expect(find.text(note), findsNothing);
    });

    testWidgets('the start as the server words it, else ours', (tester) async {
      await pumpOffers(tester, activeHome(), offers: [
        _offer(1,
            startDate: DateTime(2026, 11, 2),
            startLabel: 'Dès que possible',
            startPassed: true),
        _offer(2,
            reference: 'OFF-2611-11',
            startDate: DateTime(2020, 1, 6),
            startPassed: true),
        _offer(3, reference: 'OFF-2611-12', startDate: DateTime(2999, 1, 7)),
      ]);
      await tester.pumpAndSettle();
      expect(find.text('Début : Dès que possible'), findsNWidgets(2));
      expect(find.text('Début : Lundi 7 janvier 2999'), findsOneWidget);
    });

    testWidgets('shows the empty state', (tester) async {
      await pumpAppWith(
        tester,
        overrides: [
          tutorReferencesProvider.overrideWith((ref) async => _references),
          tutorOffersPageProvider
              .overrideWith((ref, key) async => _page(const [])),
        ],
        child: const TutorOffersPage(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucune offre pour ces critères'), findsOneWidget);
      expect(find.text('Modifier ma zone'), findsOneWidget);
    });
  });

  group('REP-11 offer', () {
    testWidgets('applies with a message, then shows the success',
        (tester) async {
      final api = _FakeApi();
      await pumpAppWith(
        tester,
        overrides: [tutorOfferApiProvider.overrideWithValue(api)],
        child: const TutorOfferPage(offerId: 7),
      );
      await tester.pumpAndSettle();

      expect(find.text('OFFRE OFF-2611-07 · PUBLIÉE LE LUN. 2 NOV.'),
          findsOneWidget);
      expect(find.text('Bonamoussadi'), findsOneWidget);
      expect(find.text('Une seule candidature par offre.'), findsOneWidget);
      final pay = find.textContaining(RegExp(r'^6\s500 FCFA$'));
      await tester.scrollUntilVisible(pay, 200,
          scrollable: find.byType(Scrollable).first);
      expect(pay, findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('offer-message')), 'Je prépare au BEPC.');
      await tester.pump();
      expect(find.text('19 / 300'), findsOneWidget);
      await tester.tap(find.text('Postuler'));
      await tester.pumpAndSettle();

      expect(api.applied.single, (7, 'Je prépare au BEPC.'));
      expect(find.text('Candidature envoyée'), findsOneWidget);
      expect(find.text('Compléter mon dossier'), findsOneWidget);
      expect(find.text('Postuler'), findsNothing);
    });

    testWidgets('shows the conflict of the server in a toast', (tester) async {
      final api = _FakeApi(
          failure:
              const ConflictFailure('Vous avez déjà postulé à cette offre.'));
      await pumpAppWith(
        tester,
        overrides: [tutorOfferApiProvider.overrideWithValue(api)],
        child: const TutorOfferPage(offerId: 7),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Postuler'));
      await tester.pump();

      expect(
          find.text('Vous avez déjà postulé à cette offre.'), findsOneWidget);
      expect(find.text('Candidature envoyée'), findsNothing);
    });

    testWidgets('says the tutor already applied, without the form',
        (tester) async {
      await pumpAppWith(
        tester,
        overrides: [
          tutorOfferProvider
              .overrideWith((ref, id) async => _offer(id, applied: true)),
        ],
        child: const TutorOfferPage(offerId: 7),
      );
      await tester.pumpAndSettle();

      expect(find.text('Lundi 16 novembre'), findsOneWidget);
      expect(find.text('Vous avez déjà postulé le Mardi 24 novembre'),
          findsOneWidget);
      expect(find.text('Voir'), findsOneWidget);
      expect(find.text('Postuler'), findsNothing);
      expect(find.byKey(const Key('offer-message')), findsNothing);
    });
  });

  testWidgets('REP-11 offer: the start label of the server', (tester) async {
    await pumpAppWith(
      tester,
      overrides: [
        tutorOfferProvider.overrideWith((ref, id) async => _offer(id,
            applied: true,
            startDate: DateTime(2026, 11, 2),
            startLabel: 'Dès que possible',
            startPassed: true)),
      ],
      child: const TutorOfferPage(offerId: 7),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dès que possible'), findsOneWidget);
    expect(find.text('Lundi 2 novembre'), findsNothing);
  });

  group('REP-12 applications', () {
    testWidgets('lists the applications and SOE answer', (tester) async {
      await pumpAppWith(
        tester,
        overrides: [
          tutorApplicationsProvider.overrideWith((ref) async => [
                TutorApplication(
                    id: 1,
                    status: 'selected',
                    statusLabel: 'Retenue',
                    sentAt: DateTime(2026, 11, 12),
                    message: null,
                    offerId: 11,
                    reference: 'OFF-2611-11',
                    subjects: const ['Mathématiques'],
                    schoolClass: 'Tle D',
                    neighborhood: 'Kotto'),
              ]),
        ],
        child: const TutorApplicationsPage(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mes candidatures'), findsOneWidget);
      expect(find.text('Mathématiques · Tle D'), findsOneWidget);
      expect(find.text('Kotto · envoyée le Jeu. 12 nov.'), findsOneWidget);
      expect(find.text('Retenue'), findsOneWidget);
      expect(find.textContaining('SOE pourra vous proposer'), findsOneWidget);
    });

    testWidgets('shows the empty state', (tester) async {
      await pumpAppWith(
        tester,
        overrides: [tutorApplicationsProvider.overrideWith((ref) async => [])],
        child: const TutorApplicationsPage(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aucune candidature'), findsOneWidget);
      expect(find.text('Voir les offres'), findsOneWidget);
    });
  });
}
