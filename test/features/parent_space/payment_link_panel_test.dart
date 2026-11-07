import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/services/share_service.dart';
import 'package:soe/core/widgets/soe_adaptive_panel.dart';
import 'package:soe/core/widgets/soe_card.dart';
import 'package:soe/features/parent_space/data/parent_api.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_payments_page.dart';
import 'package:soe/features/parent_space/presentation/providers.dart';
import 'package:soe/features/parent_space/presentation/widgets/payment_link_panel.dart';

import '../../helpers/pump_app.dart';

class _MockApi extends Mock implements ParentApi {}

class _FakeShare implements ShareService {
  final shared = <String>[];
  final copied = <String>[];

  @override
  Future<void> share(String text, {String? subject}) async => shared.add(text);

  @override
  Future<void> copy(String text) async => copied.add(text);
}

const _url = 'https://www.soe.test/fr/payer/abc123';

ParentInvoice _invoice({String status = 'issued', bool holder = true}) =>
    ParentInvoice.fromJson({
      'id': 2,
      'number': 'INV-202611-93EE87',
      'period': '2026-11-01',
      'amount': 150000,
      'balance_due': 150000,
      'status': status,
      'due_on': '2026-11-05',
      if (holder) 'payment_link': null,
    });

PaymentLink _link(String url) => PaymentLink(
    url: url,
    status: PaymentLinkStatus.active,
    expiresAt: DateTime(2026, 12, 5));

/// « Faire payer quelqu'un d'autre » — the payment link: shared, copied, renewed, deactivated;
/// never offered to a co-parent nor on a paid invoice; readable on a tablet.
void main() {
  late _MockApi api;
  late _FakeShare share;

  setUp(() {
    api = _MockApi();
    share = _FakeShare();
    when(() => api.invoices()).thenAnswer((_) async => [_invoice()]);
    when(() => api.payments()).thenAnswer((_) async => const []);
    when(() => api.paymentLink(2)).thenAnswer((_) async => null);
    when(() => api.createPaymentLink(2)).thenAnswer((_) async => _link(_url));
    when(() => api.regeneratePaymentLink(2))
        .thenAnswer((_) async => _link('$_url-new'));
    when(() => api.revokePaymentLink(2)).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, Widget child,
      {Size size = const Size(390, 1600)}) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpAppWith(tester, child: child, overrides: [
      parentApiProvider.overrideWithValue(api),
      shareServiceProvider.overrideWithValue(share),
    ]);
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Faire payer quelqu’un d’autre'));
    await tester.tap(find.text('Faire payer quelqu’un d’autre'));
    await tester.pumpAndSettle();
  }

  testWidgets('opening creates the link; share and copy send it',
      (tester) async {
    await pump(tester, const ParentPayPage(invoiceId: 2));
    await open(tester);

    expect(find.byType(BottomSheet), findsOneWidget);
    verify(() => api.createPaymentLink(2)).called(1);
    expect(find.text(_url), findsOneWidget);
    expect(find.textContaining('Actif'), findsOneWidget);

    await tester.tap(find.text('Partager'));
    await tester.pumpAndSettle();
    expect(share.shared.single, contains(_url));
    expect(share.shared.single, startsWith('Bonjour, voici le lien'));
    expect(share.shared.single, contains('150'));

    await tester.tap(find.text('Copier le lien'));
    await tester.pumpAndSettle();
    expect(share.copied, [_url]);
    expect(find.text('Lien copié'), findsOneWidget);
  });

  testWidgets('a new link and a deactivation ask first', (tester) async {
    await pump(tester, const ParentPayPage(invoiceId: 2));
    await open(tester);

    await tester.tap(find.text('Nouveau lien').first);
    await tester.pumpAndSettle();
    expect(find.text('Créer un nouveau lien ?'), findsOneWidget);
    await tester.tap(find.text('Nouveau lien').last);
    await tester.pumpAndSettle();
    verify(() => api.regeneratePaymentLink(2)).called(1);
    expect(find.text('$_url-new'), findsOneWidget);

    await tester.tap(find.text('Désactiver').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Désactiver').last);
    await tester.pumpAndSettle();
    verify(() => api.revokePaymentLink(2)).called(1);
    expect(find.text('Créer le lien'), findsOneWidget);
  });

  testWidgets('a co-parent and a paid invoice have no link to share',
      (tester) async {
    await pump(
        tester,
        Scaffold(
            body: Column(children: [
          PaymentLinkAction(invoice: _invoice(holder: false)),
          PaymentLinkAction(invoice: _invoice(status: 'paid')),
        ])));
    expect(find.text('Faire payer quelqu’un d’autre'), findsNothing);
  });

  testWidgets(
      'on a tablet the pay screen keeps a readable width and the link opens as a dialog',
      (tester) async {
    await pump(tester, const ParentPayPage(invoiceId: 2),
        size: const Size(1024, 1366));

    for (final card in tester.widgetList<SoeCard>(find.byType(SoeCard))) {
      final width = tester.getSize(find.byWidget(card)).width;
      expect(width, lessThanOrEqualTo(soeReadableMaxWidth));
    }
    await open(tester);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    // The panel's content (inside the dialog's padding) stays at the readable width.
    expect(tester.getSize(find.byType(PaymentLinkPanel)).width,
        lessThanOrEqualTo(soeReadableMaxWidth));
  });

  testWidgets('the invoice list offers the link under « Payer »',
      (tester) async {
    await pump(tester, const ParentPaymentsPage(), size: const Size(834, 1600));
    expect(find.text('Faire payer quelqu’un d’autre'), findsOneWidget);
    final card = tester.getSize(find.byType(SoeCard).first);
    expect(card.width, lessThanOrEqualTo(soeReadableMaxWidth));
  });
}
