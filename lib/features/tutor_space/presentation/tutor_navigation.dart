import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../i18n/translations.g.dart';
import 'providers.dart';
import 'tutor_space_routes.dart';

/// The candidate's version of a recruitment screen (REP-01 « Mode recrutement »): the file
/// under « Dossier », the offers and an offer under « Offres », the applications under
/// « Candidatures ». An active tutor keeps the paths of « Plus ».
String tutorPath(BuildContext context, String path) {
  if (!_candidate(context)) return path;
  final direct = const {
    TutorSpaceRoutes.file: RouteNames.tutorCandidateFile,
    TutorSpaceRoutes.offers: RouteNames.tutorCandidateOffers,
    TutorSpaceRoutes.applications: RouteNames.tutorCandidateApplications,
  }[path];
  if (direct != null) return direct;
  final offer = RegExp(r'^/tutor/space/offers/(\d+)$').firstMatch(path);
  return offer == null
      ? path
      : '${RouteNames.tutorCandidateOffers}/${offer.group(1)}';
}

/// Opens a tutor screen: a candidate's tab is switched to, any other screen is pushed.
void openTutorScreen(BuildContext context, String path) {
  final target = tutorPath(context, path);
  if (RouteNames.tabRoots.contains(target)) {
    context.go(target);
  } else {
    unawaited(context.push(target));
  }
}

/// Goes to a tutor screen, replacing the history of its tab.
void goTutorScreen(BuildContext context, String path) =>
    context.go(tutorPath(context, path));

/// The breadcrumb of a screen of « Plus » (« Plus › Offres »); none in a candidate's tab.
String? tutorMoreSection(BuildContext context) =>
    _candidate(context) ? null : Translations.of(context).shell.more.tab;

bool _candidate(BuildContext context) =>
    ProviderScope.containerOf(context, listen: false)
        .read(tutorCandidateProvider);
