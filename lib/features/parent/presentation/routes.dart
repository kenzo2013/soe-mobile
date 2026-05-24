import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/parent_dashboard_page.dart';
import 'pages/parent_home_placeholder.dart';

List<RouteBase> parentRoutes() => [
      GoRoute(
        path: RouteNames.parentDashboard,
        builder: (context, state) => const ParentDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.parentStudents,
        builder: (context, state) => const ParentHomePlaceholderPage(),
      ),
      GoRoute(
        path: RouteNames.parentReservations,
        builder: (context, state) => const ParentHomePlaceholderPage(),
      ),
      GoRoute(
        path: RouteNames.parentSessions,
        builder: (context, state) => const ParentHomePlaceholderPage(),
      ),
      GoRoute(
        path: RouteNames.parentPayments,
        builder: (context, state) => const ParentHomePlaceholderPage(),
      ),
    ];
