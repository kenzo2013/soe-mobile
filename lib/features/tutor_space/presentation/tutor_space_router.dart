import 'package:go_router/go_router.dart';

import 'pages/tutor_contract_pages.dart';
import 'pages/tutor_proposal_page.dart';
import 'pages/tutor_report_page.dart';
import 'pages/tutor_session_page.dart';
import 'pages/tutor_times_page.dart';

/// The id of a path (`0` when malformed: the screen then shows « not found »).
int _id(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

/// Full-screen routes of the tutor space v2 (lot 4), opened from its tabs.
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
        path: '/tutor/space/contracts/:id',
        builder: (context, state) => TutorContractPage(contractId: _id(state)),
      ),
    ];
