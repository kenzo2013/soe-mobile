import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';

import 'pages/tutor_charter_page.dart';
import 'pages/tutor_contract_pages.dart';
import 'pages/tutor_earnings_page.dart';
import 'pages/tutor_file_pages.dart';
import 'pages/tutor_interview_page.dart';
import 'pages/tutor_offer_pages.dart';
import 'pages/tutor_payout_pages.dart';
import 'pages/tutor_proposal_page.dart';
import 'pages/tutor_quality_page.dart';
import 'pages/tutor_report_page.dart';
import 'pages/tutor_session_page.dart';
import 'pages/tutor_student_pages.dart';
import 'pages/tutor_times_page.dart';

/// The id of a path (`0` when malformed: the screen then shows « not found »).
int _id(GoRouterState state, [String name = 'id']) =>
    int.tryParse(state.pathParameters[name] ?? '') ?? 0;

/// The detail screens shown inside a tab, under its tab bar (Studio 390: « Planning ›
/// Séance », « Plus › Contrats »), by branch: 1 Planning, 2 Élèves, 3 Revenus, 4 Plus. The
/// flows with their own bottom action (report, times, signature, file forms, the interview, the
/// charter, a letter to read and sign) stay full screen.
const Map<String, int> tutorTabScreens = {
  '/tutor/space/sessions/:id': 1,
  '/tutor/space/students/:id': 2,
  '/tutor/space/earnings/history': 3,
  '/tutor/space/contracts': 4,
  '/tutor/space/file': 4,
  '/tutor/space/offers': 4,
  '/tutor/space/offers/:id': 4,
  '/tutor/space/applications': 4,
  '/tutor/space/payout-methods': 4,
  '/tutor/space/quality': 4,
};

/// The branches of a candidate (REP-01 « Mode recrutement », REP-02, REP-10 to REP-12):
/// « Offres » (the list, then an offer) and « Candidatures »; the file sits under
/// « Dossier », after the home ([tutorCandidateFileRoute]).
List<RouteBase> tutorCandidateOffersRoutes() => [
      GoRoute(
        path: RouteNames.tutorCandidateOffers,
        builder: (context, state) => const TutorOffersPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => TutorOfferPage(offerId: _id(state)),
          ),
        ],
      ),
    ];

List<RouteBase> tutorCandidateApplicationsRoutes() => [
      GoRoute(
        path: RouteNames.tutorCandidateApplications,
        builder: (context, state) => const TutorApplicationsPage(),
      ),
    ];

/// The candidate's file, under the home of « Dossier » (back returns to the home).
GoRoute tutorCandidateFileRoute() => GoRoute(
      path: 'candidate/file',
      builder: (context, state) => const TutorFilePage(),
    );

/// The routes of [tutorTabScreens] for the tab [index].
List<RouteBase> tutorTabRoutes(int index) => _tutorRoutes()
    .where((route) => tutorTabScreens[route.path] == index)
    .toList();

/// Full-screen routes of the tutor space v2, opened from its tabs, the home and « Plus ». They
/// come before the tabs in the router.
List<RouteBase> tutorSpaceRoutes() => _tutorRoutes()
    .where((route) => !tutorTabScreens.containsKey(route.path))
    .toList();

List<GoRoute> _tutorRoutes() => [
      GoRoute(
        path: '/tutor/space/sessions/:id',
        builder: (context, state) => TutorSessionPage(sessionId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/sessions/:id/report',
        builder: (context, state) => TutorReportPage(
            sessionId: _id(state),
            fromToday: state.uri.queryParameters['from'] == 'today'),
      ),
      GoRoute(
        path: '/tutor/space/proposals/:id',
        builder: (context, state) => TutorProposalPage(proposalId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/slots/:id/times',
        builder: (context, state) => TutorTimesPage(slotId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/contracts',
        builder: (context, state) => const TutorContractsPage(),
      ),
      GoRoute(
        path: '/tutor/space/contracts/:id',
        builder: (context, state) => TutorContractPage(contractId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/contracts/:id/amendments/:amendmentId',
        builder: (context, state) => TutorAmendmentPage(
            contractId: _id(state), amendmentId: _id(state, 'amendmentId')),
      ),
      GoRoute(
        path: '/tutor/space/file',
        builder: (context, state) => const TutorFilePage(),
      ),
      GoRoute(
        path: '/tutor/space/file/:section',
        builder: (context, state) => TutorFileSectionPage(
            section: state.pathParameters['section'] ?? ''),
      ),
      GoRoute(
        path: '/tutor/space/interview',
        builder: (context, state) => const TutorInterviewPage(),
      ),
      GoRoute(
        path: '/tutor/space/charter',
        builder: (context, state) => const TutorCharterPage(),
      ),
      GoRoute(
        path: '/tutor/space/offers',
        builder: (context, state) => const TutorOffersPage(),
      ),
      GoRoute(
        path: '/tutor/space/offers/:id',
        builder: (context, state) => TutorOfferPage(offerId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/applications',
        builder: (context, state) => const TutorApplicationsPage(),
      ),
      GoRoute(
        path: '/tutor/space/students/:id',
        builder: (context, state) => TutorStudentPage(studentId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/earnings/history',
        builder: (context, state) => const TutorEarningsHistoryPage(),
      ),
      GoRoute(
        path: '/tutor/space/payout-methods',
        builder: (context, state) => const TutorPayoutMethodsPage(),
      ),
      GoRoute(
        path: '/tutor/space/quality',
        builder: (context, state) => const TutorQualityPage(),
      ),
    ];
