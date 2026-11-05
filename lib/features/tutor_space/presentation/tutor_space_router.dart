import 'package:go_router/go_router.dart';

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

/// Full-screen routes of the tutor space v2, opened from its tabs, the home and « Plus ».
List<RouteBase> tutorSpaceRoutes() => [
      GoRoute(
        path: '/tutor/space/sessions/:id',
        builder: (context, state) => TutorSessionPage(sessionId: _id(state)),
      ),
      GoRoute(
        path: '/tutor/space/sessions/:id/report',
        builder: (context, state) => TutorReportPage(sessionId: _id(state)),
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
