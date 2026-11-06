import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/widgets/soe_button.dart';
import 'package:soe/features/parent_space/data/parent_api.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';
import 'package:soe/features/parent_space/presentation/pages/parent_payments_page.dart';
import 'package:soe/features/parent_space/presentation/providers.dart';

import '../../helpers/pump_app.dart';

class _MockApi extends Mock implements ParentApi {}

// « Payer 150 000 FCFA » (the amount is formatted with non-breaking spaces).
final _payButton = find.byWidgetPredicate(
    (widget) => widget is SoeButton && widget.label.startsWith('Payer '));

/// PAR-16 — pay an invoice: the operator comes from the number typed, can be changed, and is
/// sent with the number in +237 form.
void main() {
  late _MockApi api;

  setUp(() {
    api = _MockApi();
    when(() => api.invoices()).thenAnswer((_) async => [
          ParentInvoice.fromJson({
            'id': 2,
            'number': 'INV-202611-93EE87',
            'period': '2026-11-01',
            'amount': 150000,
            'balance_due': 150000,
            'can_pay': true,
          })
        ]);
    // The page stays open (no router in the test): the request is checked, not the follow-up.
    when(() => api.pay(any(),
        operator: any(named: 'operator'),
        phone: any(named: 'phone'))).thenThrow(const NetworkFailure());
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await pumpAppWith(tester,
        child: const ParentPayPage(invoiceId: 2),
        overrides: [parentApiProvider.overrideWithValue(api)]);
    await tester.pumpAndSettle();
  }

  testWidgets('the number gives the operator; the request carries both',
      (tester) async {
    await pump(tester);
    expect(find.text('Paiement Mobile Money'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '6 99 00 00 00');
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Si la demande n’apparaît pas, composez #150# (Orange Money).'),
        findsOneWidget);
    await tester.tap(_payButton);
    await tester.pumpAndSettle();

    verify(() => api.pay(2, operator: 'orange', phone: '+237699000000'))
        .called(1);
  });

  testWidgets('the operator chosen by hand is the one sent', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), '677000000');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ce n’est pas le bon opérateur ?'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Orange Money'));
    await tester.pumpAndSettle();
    await tester.tap(_payButton);
    await tester.pumpAndSettle();

    verify(() => api.pay(2, operator: 'orange', phone: '+237677000000'))
        .called(1);
  });

  testWidgets('no operator recognised: the pay button waits for a choice',
      (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextFormField), '685000000');
    await tester.pumpAndSettle();
    await tester.tap(_payButton);
    await tester.pumpAndSettle();

    verifyNever(() => api.pay(any(),
        operator: any(named: 'operator'), phone: any(named: 'phone')));
  });
}
