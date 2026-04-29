import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/widgets/soe_avatar.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('SoeAvatar shows initials from name', (tester) async {
    await pumpAppWith(tester, child: const SoeAvatar(name: 'Jean Dupont'));
    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets('SoeAvatar shows ? when name is null/empty', (tester) async {
    await pumpAppWith(tester, child: const SoeAvatar(name: '   '));
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('SoeAvatar single name keeps single initial', (tester) async {
    await pumpAppWith(tester, child: const SoeAvatar(name: 'Cher'));
    expect(find.text('C'), findsOneWidget);
  });
}
