import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/parent_space/data/parent_api.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';

import '../../helpers/fake_api.dart';

/// The payment link of an invoice: read, created, renewed, deactivated; holder only.
void main() {
  final link = {
    'url': 'https://www.soe.test/fr/payer/abc123',
    'status': 'active',
    'expires_at': '2026-12-05T23:59:00Z',
    'created_at': '2026-11-06T10:00:00Z',
  };

  test('reads the link; none yet is null, not an error', () async {
    final fake = FakeApi()
      ..on('GET /parent/invoices/2/payment_link', (200, envelope(link)));
    final api = ParentApi(fake.dio);

    final read = await api.paymentLink(2);
    expect(read!.url, 'https://www.soe.test/fr/payer/abc123');
    expect(read.status, PaymentLinkStatus.active);
    expect(read.usable, isTrue);
    expect(read.expiresAt!.toUtc(), DateTime.utc(2026, 12, 5, 23, 59));

    expect(await api.paymentLink(3), isNull); // unknown route: 404
  });

  test('creates, regenerates and deactivates', () async {
    final fake = FakeApi()
      ..on('POST /parent/invoices/2/payment_link', (201, envelope(link)))
      ..on('POST /parent/invoices/2/payment_link/regenerate', (
        201,
        envelope({...link, 'url': 'https://www.soe.test/fr/payer/new'})
      ))
      ..on('DELETE /parent/invoices/2/payment_link', (204, null));
    final api = ParentApi(fake.dio);

    expect((await api.createPaymentLink(2)).url, endsWith('/abc123'));
    expect((await api.regeneratePaymentLink(2)).url, endsWith('/new'));
    await api.revokePaymentLink(2);
    expect(fake.sent('DELETE /parent/invoices/2/payment_link'), hasLength(1));
  });

  test('a co-parent is refused; an invoice no longer payable too', () async {
    final fake = FakeApi()
      ..on('POST /parent/invoices/2/payment_link', (
        403,
        {
          'errors': [
            {'code': 'forbidden', 'message': 'Forbidden', 'field': null}
          ]
        }
      ))
      ..on('POST /parent/invoices/4/payment_link',
          invalid('invoice', 'Cette facture ne peut plus être payée.'));
    final api = ParentApi(fake.dio);

    await expectLater(
        api.createPaymentLink(2), throwsA(isA<ForbiddenFailure>()));
    await expectLater(api.createPaymentLink(4), throwsA(isA<Failure>()));
  });

  test('the invoice tells whether its link can be shared', () {
    Map<String, dynamic> invoice(String status, {bool holder = true}) => {
          'id': 2,
          'number': 'INV-1',
          'period': '2026-11-01',
          'amount': 150000,
          'balance_due': 150000,
          'status': status,
          if (holder) 'payment_link': null,
        };

    expect(ParentInvoice.fromJson(invoice('issued')).canShareLink, isTrue);
    expect(
        ParentInvoice.fromJson(invoice('issued', holder: false)).canShareLink,
        isFalse);
    expect(ParentInvoice.fromJson(invoice('paid')).canShareLink, isFalse);
    expect(
        ParentInvoice.fromJson({...invoice('overdue'), 'payment_link': link})
            .paymentLink!
            .status,
        PaymentLinkStatus.active);
    expect(PaymentLinkStatus.parse('whatever'), PaymentLinkStatus.expired);
  });
}
