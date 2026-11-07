import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/data/mobile_money_operator.dart';
import 'package:soe/core/widgets/soe_mobile_money_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<ValueNotifier<MobileMoneyOperator?>> pump(WidgetTester tester,
      {String text = ''}) async {
    tester.view.physicalSize = const Size(600 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final chosen =
        ValueNotifier<MobileMoneyOperator?>(MobileMoneyOperator.detect(text));
    final controller = TextEditingController(text: text);
    await pumpAppWith(tester,
        child: Scaffold(
          body: ValueListenableBuilder<MobileMoneyOperator?>(
            valueListenable: chosen,
            builder: (_, operator, __) => SoeMobileMoneyField(
              controller: controller,
              operator: operator,
              onOperatorChanged: (value) => chosen.value = value,
            ),
          ),
        ));
    await tester.pumpAndSettle();
    return chosen;
  }

  testWidgets('typing the number shows the operator found from its prefix',
      (tester) async {
    final chosen = await pump(tester);

    await tester.enterText(find.byType(TextFormField), '677');
    await tester.pumpAndSettle();
    expect(chosen.value, MobileMoneyOperator.mtn);
    expect(find.bySemanticsLabel('Opérateur détecté : MTN Mobile Money'),
        findsOneWidget);
    expect(find.text('Ce n’est pas le bon opérateur ?'), findsOneWidget);
    expect(find.text('Choisissez l’opérateur'), findsNothing);

    await tester.enterText(find.byType(TextFormField), '699 00 00 00');
    await tester.pumpAndSettle();
    expect(chosen.value, MobileMoneyOperator.orange);
  });

  testWidgets('« Ce n’est pas le bon opérateur ? » lets the parent choose',
      (tester) async {
    final chosen = await pump(tester, text: '678267282');
    expect(chosen.value, MobileMoneyOperator.mtn);

    await tester.tap(find.text('Ce n’est pas le bon opérateur ?'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Orange Money'));
    await tester.pumpAndSettle();

    expect(chosen.value, MobileMoneyOperator.orange);
    expect(find.text('Choisissez l’opérateur'), findsNothing);

    // Another digit of the same operator keeps the choice made by hand.
    await tester.enterText(find.byType(TextFormField), '6782672821');
    await tester.pumpAndSettle();
    expect(chosen.value, MobileMoneyOperator.orange);
  });

  testWidgets('an unknown prefix shows the two operators to choose from',
      (tester) async {
    final chosen = await pump(tester);

    await tester.enterText(find.byType(TextFormField), '685');
    await tester.pumpAndSettle();

    expect(chosen.value, isNull);
    expect(find.text('Opérateur non reconnu : choisissez-le ci-dessous.'),
        findsOneWidget);
    await tester.tap(find.bySemanticsLabel('MTN Mobile Money'));
    await tester.pumpAndSettle();
    expect(chosen.value, MobileMoneyOperator.mtn);
  });
}
