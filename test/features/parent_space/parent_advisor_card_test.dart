import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/parent_space/data/parent_models.dart';
import 'package:soe/features/parent_space/presentation/providers.dart';
import 'package:soe/features/parent_space/presentation/widgets/parent_advisor_card.dart';

import '../../helpers/pump_app.dart';

const _home = ParentHome(
  actions: [],
  weekSessions: [],
  requests: [],
  children: [],
  invoice: null,
  advisorName: 'Carine Ekotto',
  advisorPhone: '+237 675 94 23 44',
);

void main() {
  // The tablet home puts the card in a narrow side column: « WhatsApp » used to break into
  // « WhatsAp / p ».
  testWidgets(
      'the call and WhatsApp labels stay on one line in a narrow column',
      (tester) async {
    await pumpAppWith(tester,
        child: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 240, child: ParentAdvisorCard()),
          ),
        ),
        overrides: [parentHomeProvider.overrideWith((ref) async => _home)]);
    await tester.pumpAndSettle();

    for (final label in ['Appeler', 'WhatsApp']) {
      final text = find.text(label);
      expect(text, findsOneWidget);
      final style = DefaultTextStyle.of(tester.element(text)).style;
      final lineHeight = (style.fontSize ?? 14) * (style.height ?? 1.5);
      expect(tester.getSize(text).height, lessThan(lineHeight * 1.5));
    }
    expect(tester.takeException(), isNull);
  });
}
