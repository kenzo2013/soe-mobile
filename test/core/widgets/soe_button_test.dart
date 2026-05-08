import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/widgets/soe_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('SoeButton renders label and triggers onPressed', (tester) async {
    var taps = 0;
    await pumpAppWith(
      tester,
      child: SoeButton(label: 'Valider', onPressed: () => taps++),
    );
    expect(find.text('Valider'), findsOneWidget);
    await tester.tap(find.text('Valider'));
    expect(taps, 1);
  });

  testWidgets('SoeButton disabled when onPressed null', (tester) async {
    await pumpAppWith(
      tester,
      child: const SoeButton(label: 'Off', onPressed: null),
    );
    final opacity = tester.widget<Opacity>(find.byType(Opacity).first).opacity;
    expect(opacity, lessThan(1));
  });

  testWidgets('SoeButton in loading state shows spinner alongside label',
      (tester) async {
    await pumpAppWith(
      tester,
      child: SoeButton(
        label: 'Saving',
        loading: true,
        onPressed: () {},
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Le design auth garde le libellé visible à côté du spinner
    // (« Connexion en cours… »).
    expect(find.text('Saving'), findsOneWidget);
  });
}
