import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/parent_child_detail_page.dart';
import 'pages/parent_child_form_page.dart';
import 'pages/parent_children_list_page.dart';
import 'pages/parent_dashboard_page.dart';
import 'pages/parent_home_placeholder.dart';
import 'pages/parent_new_reservation_page.dart';
import 'pages/parent_reservation_detail_page.dart';
import 'pages/parent_reservations_list_page.dart';
import 'pages/parent_session_detail_page.dart';
import 'pages/parent_sessions_list_page.dart';
import 'pages/parent_tutor_profile_page.dart';

List<RouteBase> parentRoutes() => [
      GoRoute(
        path: RouteNames.parentDashboard,
        builder: (context, state) => const ParentDashboardPage(),
      ),
      GoRoute(
        path: RouteNames.parentStudents,
        builder: (context, state) => const ParentChildrenListPage(),
      ),
      GoRoute(
        path: RouteNames.parentStudentNew,
        builder: (context, state) => const ParentChildFormPage(),
      ),
      GoRoute(
        path: '/parent/students/:id',
        builder: (context, state) => ParentChildDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/parent/students/:id/edit',
        builder: (context, state) => ParentChildFormPage(
          editId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/parent/tutors/:id',
        builder: (context, state) => ParentTutorProfilePage(
          tutorId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.parentReservations,
        builder: (context, state) => const ParentReservationsListPage(),
      ),
      GoRoute(
        path: '/parent/reservations/new',
        builder: (context, state) => const ParentNewReservationPage(),
      ),
      GoRoute(
        path: '/parent/reservations/:id',
        builder: (context, state) => ParentReservationDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.parentSessions,
        builder: (context, state) => const ParentSessionsListPage(),
      ),
      GoRoute(
        path: '/parent/sessions/:id',
        builder: (context, state) => ParentSessionDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: RouteNames.parentPayments,
        builder: (context, state) => const ParentHomePlaceholderPage(),
      ),
    ];
