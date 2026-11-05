import 'package:go_router/go_router.dart';

import 'pages/parent_children_page.dart';
import 'pages/parent_payments_page.dart';
import 'pages/parent_request_pages.dart';
import 'pages/parent_session_pages.dart';

/// The id of a path (`0` when malformed: the screen then shows « not found »).
int _id(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

/// Full-screen routes of the parent space v2 (lot 3), opened from its tabs.
List<RouteBase> parentSpaceRoutes() => [
      GoRoute(
        path: '/parent/space/sessions/:id',
        builder: (context, state) => ParentSessionPage(sessionId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/sessions/:id/report',
        builder: (context, state) => ParentReportPage(sessionId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/children/:id',
        builder: (context, state) => ParentChildPage(childId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/invoices/:id/pay',
        builder: (context, state) => ParentPayPage(invoiceId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/payments/:id',
        builder: (context, state) => ParentPaymentPage(paymentId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/requests',
        builder: (context, state) => const ParentRequestsPage(),
      ),
      GoRoute(
        path: '/parent/space/requests/:id/quote',
        builder: (context, state) => ParentQuotePage(requestId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/requests/:id/planning',
        builder: (context, state) =>
            ParentPlanningProposalPage(requestId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/contracts/:id',
        builder: (context, state) => ParentContractPage(contractId: _id(state)),
      ),
    ];
