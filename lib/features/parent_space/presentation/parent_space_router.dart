import 'package:go_router/go_router.dart';

import 'pages/parent_children_page.dart';
import 'pages/parent_payments_page.dart';
import 'pages/parent_session_pages.dart';

/// Full-screen routes of the parent space v2 (lot 3), opened from its tabs.
List<RouteBase> parentSpaceRoutes() => [
      GoRoute(
        path: '/parent/space/sessions/:id',
        builder: (context, state) => ParentSessionPage(
            sessionId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/parent/space/sessions/:id/report',
        builder: (context, state) =>
            ParentReportPage(sessionId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/parent/space/children/:id',
        builder: (context, state) =>
            ParentChildPage(childId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/parent/space/invoices/:id/pay',
        builder: (context, state) =>
            ParentPayPage(invoiceId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/parent/space/payments/:id',
        builder: (context, state) => ParentPaymentPage(
            paymentId: int.parse(state.pathParameters['id']!)),
      ),
    ];
