import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/widgets/soe_badge.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('SoeBadge displays its label', (tester) async {
    await pumpAppWith(
      tester,
      child: const SoeBadge(label: 'Payé', tone: SoeBadgeTone.success),
    );
    expect(find.text('Payé'), findsOneWidget);
  });

  testWidgets('Status enums map to badges with French labels', (tester) async {
    await pumpAppWith(
      tester,
      child: PaymentStatus.completed.toBadge(),
    );
    expect(find.text('Payé'), findsOneWidget);
  });

  testWidgets('ReservationStatus.pending → "En attente"', (tester) async {
    await pumpAppWith(
      tester,
      child: ReservationStatus.pending.toBadge(),
    );
    expect(find.text('En attente'), findsOneWidget);
  });
}
