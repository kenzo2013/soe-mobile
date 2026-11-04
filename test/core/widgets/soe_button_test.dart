import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/theme/app_palette.dart';
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
    // Studio: disabled = n300 background, ink600 text, not announced as enabled.
    final material = tester.widget<Material>(
      find
          .descendant(
              of: find.byType(SoeButton), matching: find.byType(Material))
          .first,
    );
    expect(material.color, AppPalette.n300);
    final text = tester.widget<Text>(find.text('Off'));
    expect(text.style?.color, AppPalette.ink600);
    expect(tester.getSemantics(find.byType(SoeButton)),
        matchesSemantics(isButton: true, hasEnabledState: true, label: 'Off'));
  });

  testWidgets('SoeButton variants follow the Studio matrix', (tester) async {
    await pumpAppWith(
      tester,
      child: Column(children: [
        SoeButton(label: 'Payer', onPressed: () {}),
        SoeButton(
            label: 'Accepter',
            variant: SoeButtonVariant.secondary,
            onPressed: () {}),
      ]),
    );
    final colors = tester
        .widgetList<Material>(find.descendant(
            of: find.byType(SoeButton), matching: find.byType(Material)))
        .map((m) => m.color)
        .toList();
    expect(colors, [AppPalette.gold400, AppPalette.teal500]);
    expect(tester.getSize(find.byType(SoeButton).first).height, 52);
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

  testWidgets('SoeButton can be activated by a screen reader', (tester) async {
    var taps = 0;
    final handle = tester.ensureSemantics();
    await pumpAppWith(
      tester,
      child: SoeButton(label: 'Payer', onPressed: () => taps++),
    );
    expect(
      tester.getSemantics(find.byType(SoeButton)),
      matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          label: 'Payer'),
    );
    tester.semantics.tap(find.semantics.byLabel('Payer'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('SoeButton hugging its label fits in an unbounded Row',
      (tester) async {
    await pumpAppWith(
      tester,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [SoeButton(label: 'Modifier', onPressed: () {})]),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
