import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/features/tutor_space/data/tutor_models.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';
import 'package:soe/features/tutor_space/presentation/widgets/tutor_more_links.dart';

import '../../helpers/pump_app.dart';

TutorContract _contract({required bool canSign, int amendmentsToSign = 0}) =>
    TutorContract(
      id: 1,
      reference: 'LM-1',
      pupil: 'Samuel K.',
      subject: 'Mathématiques',
      status: canSign ? 'sent' : 'signed',
      statusLabel: '',
      receivedAt: null,
      signedAt: null,
      canSign: canSign,
      text: '',
      amendmentsToSign: amendmentsToSign,
    );

void main() {
  testWidgets('lists the tutor entries of « Plus » and what is left to sign',
      (tester) async {
    await pumpAppWith(
      tester,
      overrides: [
        tutorContractsProvider.overrideWith((ref) async => [
              _contract(canSign: true),
              _contract(canSign: false, amendmentsToSign: 1),
            ]),
      ],
      child: const Scaffold(body: TutorMoreLinks()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offres'), findsOneWidget);
    expect(find.text('Candidatures'), findsOneWidget);
    expect(find.text('Mon dossier'), findsOneWidget);
    expect(find.text('Contrats'), findsOneWidget);
    expect(find.text('2 documents à signer'), findsOneWidget);
    expect(find.text('Moyens de paiement'), findsOneWidget);
  });

  testWidgets('shows no count when nothing is to sign', (tester) async {
    await pumpAppWith(
      tester,
      overrides: [
        tutorContractsProvider
            .overrideWith((ref) async => [_contract(canSign: false)]),
      ],
      child: const Scaffold(body: TutorMoreLinks()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('à signer'), findsNothing);
  });
}
