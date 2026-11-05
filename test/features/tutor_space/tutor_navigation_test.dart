import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/features/tutor_space/presentation/providers.dart';
import 'package:soe/features/tutor_space/presentation/tutor_navigation.dart';
import 'package:soe/features/tutor_space/presentation/tutor_space_routes.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<BuildContext> pump(WidgetTester tester,
      {required bool candidate}) async {
    late BuildContext captured;
    await pumpAppWith(tester,
        overrides: [tutorCandidateProvider.overrideWithValue(candidate)],
        child: Builder(builder: (context) {
      captured = context;
      return const SizedBox();
    }));
    return captured;
  }

  testWidgets(
      'a candidate opens the file, offers and applications in their tabs',
      (tester) async {
    final context = await pump(tester, candidate: true);

    expect(tutorPath(context, TutorSpaceRoutes.file),
        RouteNames.tutorCandidateFile);
    expect(tutorPath(context, TutorSpaceRoutes.offers),
        RouteNames.tutorCandidateOffers);
    expect(tutorPath(context, TutorSpaceRoutes.offer(4)),
        '${RouteNames.tutorCandidateOffers}/4');
    expect(tutorPath(context, TutorSpaceRoutes.applications),
        RouteNames.tutorCandidateApplications);
    // The flows stay full screen.
    expect(
        tutorPath(context, TutorSpaceRoutes.charter), TutorSpaceRoutes.charter);
    expect(tutorMoreSection(context), isNull);
  });

  testWidgets('an active tutor keeps the screens of « Plus »', (tester) async {
    final context = await pump(tester, candidate: false);

    expect(tutorPath(context, TutorSpaceRoutes.offer(4)),
        TutorSpaceRoutes.offer(4));
    expect(tutorPath(context, TutorSpaceRoutes.file), TutorSpaceRoutes.file);
    expect(tutorMoreSection(context), 'Plus');
  });
}
