import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/network/paginated.dart';
import 'package:soe/core/widgets/soe_otp_field.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';
import 'package:soe/features/tutor_space/data/tutor_money_api.dart';
import 'package:soe/features/tutor_space/data/tutor_money_models.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_contract_pages.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_earnings_page.dart';
import 'package:soe/features/tutor_space/presentation/pages/tutor_payout_pages.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';
import 'package:soe/features/tutor_space/presentation/tutor_money_providers.dart';
import 'package:soe/features/tutor_space/presentation/widgets/tutor_download.dart';

import '../../helpers/pump_app.dart';

const _earnings = TutorEarnings(
  amount: 52500,
  approved: 8,
  pendingAmount: 7000,
  disputedAmount: 7000,
  pupils: [
    TutorEarningsPupil(
        name: 'Ornella T.',
        approved: 7,
        rate: 6500,
        amount: 45500,
        pending: 0,
        disputed: 0),
    TutorEarningsPupil(
        name: 'Yann M.',
        approved: 1,
        rate: null,
        amount: 7000,
        pending: 1,
        disputed: 1),
  ],
  payoutOn: null,
  defaultMethodLabel: 'MTN MoMo · •• 44 12',
  history: [
    TutorPayout(id: 31, period: null, paidAt: null, amount: 58500, sessions: 9),
  ],
);

const _mtn = TutorPayoutMethod(
    id: 1,
    kind: 'mobile',
    operator: 'mtn',
    name: 'MTN MoMo',
    detail: '+237 6 77 •• 44 12',
    isDefault: true,
    canBeDefault: false);
const _orange = TutorPayoutMethod(
    id: 2,
    kind: 'mobile',
    operator: 'orange',
    name: 'Orange Money',
    detail: '+237 6 99 •• 31 07',
    isDefault: false,
    canBeDefault: true);

TutorContract _contract({
  int id = 1,
  String status = 'sent',
  bool canSign = true,
  bool legacy = false,
  String text = '',
  String format = 'text',
  int amendments = 0,
}) =>
    TutorContract(
      id: id,
      reference: 'LDM-$id',
      pupil: 'Samuel, 1re C',
      subject: 'Mathématiques',
      status: status,
      statusLabel: status == 'sent' ? 'À signer' : 'Signée',
      receivedAt: DateTime(2026, 11, 27),
      signedAt: status == 'signed' ? DateTime(2026, 11, 3) : null,
      canSign: canSign,
      text: text,
      legacy: legacy,
      amendmentsCount: amendments,
      textFormat: format,
    );

/// Records the calls of the screens; each answer can be set by the test.
class _FakeMoneyApi extends TutorMoneyApi {
  _FakeMoneyApi() : super(Dio());

  final calls = <String>[];
  TutorPayoutChangeRequest? request;
  Failure? confirmFailure;
  Failure? requestFailure;
  Paginated<TutorStatement> statementsPage = const Paginated(
      items: [], page: 1, perPage: 20, totalCount: 0, totalPages: 1);

  @override
  Future<Paginated<TutorStatement>> statements({int page = 1}) async {
    calls.add('statements $page');
    return statementsPage;
  }

  @override
  Future<TutorDownloadLink> receiptLink(int statementId) async {
    calls.add('receipt $statementId');
    return TutorDownloadLink(
        url: Uri.parse('https://api.test/d?token=$statementId'),
        expiresAt: null);
  }

  @override
  Future<TutorPayoutMethodChange> requestPayoutChange(
      TutorPayoutChangeRequest request) async {
    this.request = request;
    if (requestFailure != null) throw requestFailure!;
    return TutorPayoutMethodChange(
        id: 9,
        action: request.kind.value,
        summary: 'Orange •• 3107',
        sentAt: DateTime(2026, 11, 5, 10),
        expiresAt: DateTime(2026, 11, 5, 10, 15),
        confirmedAt: null);
  }

  @override
  Future<TutorPayoutMethodChange> confirmPayoutChange(
      int id, String code) async {
    calls.add('confirm $id $code');
    if (confirmFailure != null) throw confirmFailure!;
    return TutorPayoutMethodChange(
        id: id,
        action: 'make_default',
        summary: '',
        sentAt: null,
        expiresAt: null,
        confirmedAt: DateTime.now());
  }

  @override
  Future<List<TutorAmendment>> amendments(int contractId) async => [
        TutorAmendment(
            id: 4,
            contractId: contractId,
            reference: 'AV-1',
            status: 'to_sign',
            statusLabel: 'À signer',
            createdAt: DateTime(2026, 10, 20),
            signedAt: null,
            canSign: true),
      ];
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  final cells = find.descendant(
      of: find.byType(SoeOtpField), matching: find.byType(TextField));
  for (var i = 0; i < code.length; i++) {
    await tester.enterText(cells.at(i), code[i]);
  }
  await tester.pump();
}

void main() {
  group('REP-19 earnings', () {
    testWidgets('shows the month, the pupils, the payout and the history',
        (tester) async {
      final api = _FakeMoneyApi();
      final opened = <Uri>[];
      await pumpAppWith(tester,
          overrides: [
            tutorEarningsProvider.overrideWith((ref) async => _earnings),
            tutorMoneyApiProvider.overrideWithValue(api),
            tutorUrlLauncherProvider.overrideWithValue((url) async {
              opened.add(url);
              return true;
            }),
          ],
          child: const TutorEarningsPage());
      await tester.pumpAndSettle();

      expect(find.text('Seules les séances validées sont payées.'),
          findsOneWidget);
      expect(find.text('montant estimé · 8 séances validées'), findsOneWidget);
      expect(find.text('Ornella T.'), findsOneWidget);
      expect(find.textContaining('7 validées × 6'), findsOneWidget);
      expect(find.text('1 validée · 1 en attente du parent · 1 contestée'),
          findsOneWidget);
      expect(find.textContaining('En attente : 7'), findsOneWidget);
      expect(find.text('date à confirmer par SOE'), findsOneWidget);
      expect(find.text('MTN MoMo · •• 44 12'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Tout l’historique'), 200);
      expect(find.text('Touchez un mois pour télécharger le reçu.'),
          findsOneWidget);
      await tester.ensureVisible(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      expect(api.calls, ['receipt 31']);
      expect(opened.single.queryParameters['token'], '31');
    });

    testWidgets('shows the empty state without any earning', (tester) async {
      await pumpAppWith(tester,
          overrides: [
            tutorEarningsProvider.overrideWith((ref) async =>
                const TutorEarnings(
                    amount: 0,
                    approved: 0,
                    pendingAmount: 0,
                    disputedAmount: 0,
                    pupils: [],
                    payoutOn: null,
                    defaultMethodLabel: null,
                    history: [])),
          ],
          child: const TutorEarningsPage());
      await tester.pumpAndSettle();

      expect(find.text('Pas encore de revenus'), findsOneWidget);
      expect(find.text('Par élève'), findsNothing);
    });

    testWidgets('the history lists every statement and pages', (tester) async {
      final api = _FakeMoneyApi()
        ..statementsPage = Paginated(items: [
          TutorStatement(
              id: 5,
              period: DateTime(2026, 10),
              receiptNumber: 'REC-5',
              amount: 58500,
              sessions: 9,
              status: 'paid',
              statusLabel: 'Versé',
              paidAt: DateTime(2026, 11, 6),
              hasReceipt: true),
          TutorStatement(
              id: 6,
              period: DateTime(2026, 9),
              receiptNumber: null,
              amount: 39000,
              sessions: 6,
              status: 'to_pay',
              statusLabel: 'À verser',
              paidAt: null,
              hasReceipt: false),
        ], page: 1, perPage: 20, totalCount: 25, totalPages: 2);
      await pumpAppWith(tester,
          overrides: [tutorMoneyApiProvider.overrideWithValue(api)],
          child: const TutorEarningsHistoryPage());
      await tester.pumpAndSettle();

      expect(find.text('Octobre 2026'), findsOneWidget);
      expect(find.text('Versé'), findsOneWidget);
      expect(find.text('À verser'), findsOneWidget);
      expect(find.text('Reçu'), findsOneWidget);
      expect(find.text('Page 1 sur 2'), findsOneWidget);

      await tester.tap(find.text('Plus anciens'));
      await tester.pumpAndSettle();
      expect(api.calls, ['statements 1', 'statements 2']);
    });
  });

  group('REP-20 payout methods', () {
    testWidgets(
        'makes a method the default: password, code, then the list again',
        (tester) async {
      final api = _FakeMoneyApi();
      var reads = 0;
      await pumpAppWith(tester,
          overrides: [
            tutorMoneyApiProvider.overrideWithValue(api),
            tutorPayoutMethodsProvider.overrideWith((ref) async {
              reads++;
              return [_mtn, _orange];
            }),
          ],
          child: const TutorPayoutMethodsPage());
      await tester.pumpAndSettle();

      expect(find.text('Par défaut'), findsOneWidget);
      await tester.tap(find.text('Orange Money'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Utiliser par défaut'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'secret');
      await tester.pump();
      await tester.tap(find.text('Recevoir le code'));
      await tester.pumpAndSettle();

      expect(api.request!.kind, TutorPayoutChangeKind.makeDefault);
      expect(api.request!.methodId, 2);
      expect(api.request!.currentPassword, 'secret');
      expect(find.text('Confirmer le changement'), findsOneWidget);

      api.confirmFailure =
          const CodeFailure(CodeProblem.invalid, 'Code incorrect.');
      await _enterCode(tester, '123456');
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();
      expect(find.text('Code incorrect.'), findsOneWidget);

      api.confirmFailure = null;
      await _enterCode(tester, '654321');
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(api.calls, ['confirm 9 123456', 'confirm 9 654321']);
      expect(find.text('Confirmer le changement'), findsNothing);
      expect(find.text('Moyens de paiement mis à jour.'), findsOneWidget);
      expect(reads, 2);
    });

    testWidgets('an expired code stops the confirmation', (tester) async {
      final api = _FakeMoneyApi()
        ..confirmFailure = const CodeFailure(
            CodeProblem.expired, 'Le code a expiré : recommencez.');
      await pumpAppWith(tester,
          overrides: [tutorMoneyApiProvider.overrideWithValue(api)],
          child: Scaffold(
            body: TutorPayoutCodeSheet(
                change: TutorPayoutMethodChange(
                    id: 9,
                    action: 'remove',
                    summary: 'MTN •• 4412',
                    sentAt: null,
                    expiresAt: DateTime(2026, 11, 5, 10, 15),
                    confirmedAt: null)),
          ));
      await tester.pumpAndSettle();
      expect(find.text('Valable jusqu’à 10:15'), findsOneWidget);

      await _enterCode(tester, '111111');
      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(find.text('Le code a expiré : recommencez.'), findsOneWidget);
      final button = tester.widget<SoeOtpField>(find.byType(SoeOtpField));
      expect(button.enabled, isFalse);
    });

    testWidgets('removing the default asks for its replacement',
        (tester) async {
      final api = _FakeMoneyApi()
        ..requestFailure = const RateLimitedFailure('Trop de demandes.');
      await pumpAppWith(tester,
          overrides: [tutorMoneyApiProvider.overrideWithValue(api)],
          child: const Scaffold(
            body: TutorPayoutChangeSheet(
                kind: TutorPayoutChangeKind.remove,
                method: _mtn,
                methods: [_mtn, _orange]),
          ));
      await tester.pumpAndSettle();

      expect(find.text('Nouveau compte par défaut'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).last, 'secret');
      await tester.pump();
      // No replacement chosen yet: the button stays off.
      await tester.tap(find.text('Recevoir le code'));
      await tester.pump();
      expect(api.request, isNull);

      await tester.tap(find.text('Orange Money · +237 6 99 •• 31 07'));
      await tester.pump();
      await tester.tap(find.text('Recevoir le code'));
      await tester.pumpAndSettle();

      expect(api.request!.replacementId, 2);
      expect(find.text('Trop de demandes.'), findsOneWidget);
    });

    testWidgets('a default without another Mobile Money cannot be removed',
        (tester) async {
      await pumpAppWith(tester,
          child: const Scaffold(
            body: TutorPayoutChangeSheet(
                kind: TutorPayoutChangeKind.remove,
                method: _mtn,
                methods: [_mtn]),
          ));
      await tester.pumpAndSettle();

      expect(find.textContaining('ajoutez d’abord un autre compte'),
          findsOneWidget);
      expect(find.text('Recevoir le code'), findsNothing);
    });
  });

  group('REP-21 contracts', () {
    testWidgets('groups the letters to sign, signed, and the former contracts',
        (tester) async {
      await pumpAppWith(tester,
          overrides: [
            tutorContractsProvider.overrideWith((ref) async => [
                  _contract(),
                  _contract(
                      id: 2, status: 'signed', canSign: false, amendments: 1),
                  _contract(
                      id: 3, status: 'signed', canSign: false, legacy: true),
                ]),
          ],
          child: const TutorContractsPage());
      await tester.pumpAndSettle();

      expect(find.text('À signer'), findsWidgets);
      expect(find.text('Signés'), findsOneWidget);
      expect(find.text('Anciens contrats'), findsOneWidget);
      expect(find.text('Contrat LDM-3'), findsOneWidget);
      expect(find.textContaining('1 avenant'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('a letter shows its summary, its text and asks to read it',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final api = _FakeMoneyApi();
      await pumpAppWith(tester,
          overrides: [
            tutorMoneyApiProvider.overrideWithValue(api),
            tutorContractTextProvider.overrideWith((ref, key) async =>
                _contract(
                    text: List.generate(40, (i) => '${i + 1}. Article\nTexte.')
                        .join('\n\n'),
                    amendments: 1)),
          ],
          child: const TutorContractPage(contractId: 1));
      await tester.pumpAndSettle();

      expect(find.text('Résumé'), findsOneWidget);
      expect(find.text('Mathématiques'), findsOneWidget);
      expect(find.text('1. Article'), findsOneWidget);
      expect(find.text('Faites défiler jusqu’au bout'), findsOneWidget);
      expect(find.text('Lisez la lettre jusqu’au bout pour pouvoir signer'),
          findsOneWidget);
      expect(find.text('FR'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);

      expect(find.text('AV-1'), findsOneWidget);
      expect(find.text('Votre signature'), findsOneWidget);
      expect(find.text('Avenants'), findsOneWidget);
    });

    testWidgets('a v1 contract reads its HTML as plain text', (tester) async {
      await pumpAppWith(tester,
          overrides: [
            tutorContractTextProvider.overrideWith((ref, key) async =>
                _contract(
                    status: 'signed',
                    canSign: false,
                    legacy: true,
                    format: 'html',
                    text: '<h2>Objet</h2><p>Le r&eacute;p&eacute;titeur.</p>')),
          ],
          child: const TutorContractPage(contractId: 1));
      await tester.pumpAndSettle();

      expect(find.text('Ancien contrat'), findsOneWidget);
      expect(find.text('Objet'), findsOneWidget);
      expect(find.text('Le répétiteur.'), findsOneWidget);
      expect(find.text('Lue en entier'), findsOneWidget);
      expect(find.text('Votre signature'), findsNothing);
    });

    testWidgets('an amendment waits for the contract signature',
        (tester) async {
      await pumpAppWith(tester,
          overrides: [
            tutorAmendmentProvider.overrideWith((ref, key) async =>
                TutorAmendment(
                    id: 4,
                    contractId: 1,
                    reference: 'AV-1',
                    status: 'pending',
                    statusLabel: 'En attente',
                    createdAt: DateTime(2026, 10, 20),
                    signedAt: null,
                    canSign: false,
                    text: '<p>Nouveaux créneaux.</p>')),
          ],
          child: const TutorAmendmentPage(contractId: 1, amendmentId: 4));
      await tester.pumpAndSettle();

      expect(find.text('Avenant AV-1'), findsOneWidget);
      expect(find.text('En attente'), findsOneWidget);
      expect(find.text('Nouveaux créneaux.'), findsOneWidget);
      expect(find.textContaining('une fois la lettre de mission signée'),
          findsOneWidget);
      expect(find.text('Signer l’avenant'), findsNothing);
    });
  });
}
