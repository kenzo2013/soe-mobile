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

/// The detail screens shown inside a tab, under its tab bar (Studio 390: « Planning ›
/// Séance », « Mes enfants › Léa », « Plus › Demandes et devis »), by tab index: 1 Planning,
/// 2 Enfants, 3 Paiements, 4 Plus (PAR-06 to PAR-09, PAR-18, PAR-19). The flows with their
/// own bottom action (request wizard, payment, a contract to read and sign, the planning to
/// validate, forms) stay full screen.
const Map<String, int> parentTabScreens = {
  '/parent/space/sessions/:id': 1,
  '/parent/space/children/:id': 2,
  '/parent/space/payments': 3,
  '/parent/space/requests': 4,
  '/parent/space/requests/:id': 4,
  '/parent/space/requests/:id/quote': 4,
  '/parent/space/requests/:id/tutors': 4,
  '/parent/space/contracts': 4,
  '/parent/space/reviews': 4,
  '/parent/space/co-parents': 4,
  '/parent/space/advisor': 4,
};

/// The routes of [parentTabScreens] for the tab [index].
List<RouteBase> parentTabRoutes(int index) => _parentRoutes()
    .where((route) => parentTabScreens[route.path] == index)
    .toList();

/// Full-screen routes of the parent space v2, opened from its tabs, the More menu and the
/// home actions. Static paths come before the `:id` ones (go_router matches in order), and
/// these routes come before the tabs in the router (`/children/new` before `/children/:id`).
List<RouteBase> parentSpaceRoutes() => _parentRoutes()
    .where((route) => !parentTabScreens.containsKey(route.path))
    .toList();

List<GoRoute> _parentRoutes() => [
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
