import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/theme/app_palette.dart';
import 'package:soe/features/auth/presentation/pages/splash_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'AUT-00: navy launch with the logo and a labelled loader, no action',
      (tester) async {
    await pumpAppWith(tester, child: const SplashPage());
    await tester.pump(const Duration(seconds: 1));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppPalette.teal800);
    expect(
        find.bySemanticsLabel('SOE — Solution of Education'), findsOneWidget);
    expect(find.bySemanticsLabel('Chargement de SOE'), findsOneWidget);
    expect(find.byType(ButtonStyleButton), findsNothing);
  });
}
