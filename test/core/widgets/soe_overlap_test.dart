import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/widgets/soe_overlap.dart';

void main() {
  testWidgets('the part of the card lying on the band still takes the taps',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: ListView(children: [
        SoeOverlap(
          overlap: 40,
          top: Container(height: 200, color: Colors.blue),
          bottom: GestureDetector(
            onTap: () => taps++,
            child: Container(
                key: const Key('card'), height: 100, color: Colors.white),
          ),
        ),
      ]),
    ));

    final card = tester.getRect(find.byKey(const Key('card')));
    expect(card.top, 160);
    expect(tester.getSize(find.byType(SoeOverlap)).height, 260);

    // 10 px below the card's top: on the band.
    await tester.tapAt(Offset(card.center.dx, card.top + 10));
    expect(taps, 1);
  });
}
