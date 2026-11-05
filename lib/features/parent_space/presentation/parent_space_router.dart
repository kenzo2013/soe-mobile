import 'package:go_router/go_router.dart';

import 'pages/parent_account_pages.dart';
import 'pages/parent_child_form_page.dart';
import 'pages/parent_children_page.dart';
import 'pages/parent_contract_pages.dart';
import 'pages/parent_payments_page.dart';
import 'pages/parent_request_detail_page.dart';
import 'pages/parent_request_pages.dart';
import 'pages/parent_request_wizard_page.dart';
import 'pages/parent_session_pages.dart';
import 'pages/parent_tutor_pages.dart';

/// The id of a path (`0` when malformed: the screen then shows « not found »).
int _id(GoRouterState state, [String name = 'id']) =>
    int.tryParse(state.pathParameters[name] ?? '') ?? 0;

/// Full-screen routes of the parent space v2, opened from its tabs, the More menu and the
/// home actions. Static paths come before the `:id` ones (go_router matches in order).
List<RouteBase> parentSpaceRoutes() => [
      GoRoute(
        path: '/parent/space/sessions/:id',
        builder: (context, state) => ParentSessionPage(
            sessionId: _id(state),
            openSerious: state.uri.queryParameters['serious'] == '1'),
      ),
      GoRoute(
        path: '/parent/space/sessions/:id/report',
        builder: (context, state) => ParentReportPage(sessionId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/children/new',
        builder: (context, state) => const ParentChildFormPage(),
      ),
      GoRoute(
        path: '/parent/space/children/:id',
        builder: (context, state) => ParentChildPage(childId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/children/:id/edit',
        builder: (context, state) => ParentChildFormPage(childId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/invoices/:id/pay',
        builder: (context, state) => ParentPayPage(invoiceId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/payments',
        builder: (context, state) => const ParentPaymentsHistoryPage(),
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
        path: '/parent/space/requests/new',
        builder: (context, state) => const ParentRequestWizardPage(),
      ),
      GoRoute(
        path: '/parent/space/requests/:id',
        builder: (context, state) =>
            ParentRequestDetailPage(requestId: _id(state)),
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
        path: '/parent/space/requests/:id/tutors',
        builder: (context, state) => ParentTutorPage(requestId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/requests/:id/replacement/new',
        builder: (context, state) => ParentReplacementPage(
            requestId: _id(state),
            slotId: int.tryParse(state.uri.queryParameters['slot'] ?? '')),
      ),
      GoRoute(
        path: '/parent/space/requests/:id/replacement',
        builder: (context, state) =>
            ParentReplacementFollowUpPage(requestId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/contracts',
        builder: (context, state) => const ParentContractsPage(),
      ),
      GoRoute(
        path: '/parent/space/contracts/:id',
        builder: (context, state) => ParentContractPage(contractId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/contracts/:id/amendments/:amendmentId',
        builder: (context, state) => ParentAmendmentPage(
            contractId: _id(state), amendmentId: _id(state, 'amendmentId')),
      ),
      GoRoute(
        path: '/parent/space/reviews',
        builder: (context, state) => const ParentReviewsPage(),
      ),
      GoRoute(
        path: '/parent/space/reviews/tutors/:id',
        builder: (context, state) => ParentReviewFormPage(tutorId: _id(state)),
      ),
      GoRoute(
        path: '/parent/space/co-parents',
        builder: (context, state) => const ParentCoParentsPage(),
      ),
      GoRoute(
        path: '/parent/space/advisor',
        builder: (context, state) => const ParentAdvisorPage(),
      ),
    ];
