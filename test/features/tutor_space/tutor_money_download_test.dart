import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/features/tutor_space/data/tutor_money_models.dart';
import 'package:soe/features/tutor_space/presentation/widgets/tutor_download.dart';

import '../../helpers/pump_app.dart';

final _link = TutorDownloadLink(
    url: Uri.parse('https://api.test/api/v2/tutor/downloads?token=t1'),
    expiresAt: null);

Future<List<Uri>> _pump(
  WidgetTester tester, {
  required Future<TutorDownloadLink> Function() fetch,
  bool opens = true,
}) async {
  final opened = <Uri>[];
  await pumpAppWith(tester,
      overrides: [
        tutorUrlLauncherProvider.overrideWithValue((url) async {
          opened.add(url);
          return opens;
        }),
      ],
      child: Scaffold(
          body:
              Center(child: TutorDownloadButton(label: 'PDF', fetch: fetch))));
  return opened;
}

void main() {
  testWidgets('fetches the link at tap time and opens it at once',
      (tester) async {
    var fetched = 0;
    final opened = await _pump(tester, fetch: () async {
      fetched++;
      return _link;
    });
    expect(fetched, 0);

    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();

    expect(fetched, 1);
    expect(opened, [_link.url]);
  });

  testWidgets('a refused link shows the server message', (tester) async {
    final opened = await _pump(tester,
        fetch: () async =>
            throw const RateLimitedFailure('Trop de téléchargements.'));

    await tester.tap(find.text('PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(opened, isEmpty);
    expect(find.text('Trop de téléchargements.'), findsOneWidget);
  });

  testWidgets('a link the phone cannot open shows an error', (tester) async {
    final opened = await _pump(tester, fetch: () async => _link, opens: false);

    await tester.tap(find.text('PDF'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(opened, [_link.url]);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
