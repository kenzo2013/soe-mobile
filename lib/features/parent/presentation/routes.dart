import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/parent_child_detail_page.dart';
import 'pages/parent_child_form_page.dart';
import 'pages/parent_misc_pages.dart';
import 'pages/parent_new_reservation_page.dart';
import 'pages/parent_payment_receipt_page.dart';
import 'pages/parent_reservation_detail_page.dart';
import 'pages/parent_reservations_list_page.dart';
import 'pages/parent_session_detail_page.dart';
import 'pages/parent_tutor_profile_page.dart';

List<RouteBase> parentRoutes() => [
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
        path: '/parent/students/:studentId/tutors/:tutorId',
        builder: (context, state) => ParentTutorProfilePage(
          studentId: state.pathParameters['studentId']!,
          tutorId: state.pathParameters['tutorId']!,
        ),
      ),
      GoRoute(
        path: RouteNames.parentReservations,
        builder: (context, state) => const ParentReservationsListPage(),
      ),
      GoRoute(
        path: RouteNames.parentReservationNew,
        builder: (context, state) => const ParentNewReservationPage(),
      ),
      GoRoute(
        path: '/parent/reservations/:id',
        builder: (context, state) => ParentReservationDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/parent/sessions/:id',
        builder: (context, state) => ParentSessionDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/parent/payments/:id',
        builder: (context, state) => ParentPaymentReceiptPage(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/parent/reviews',
        builder: (context, state) => const ParentReviewsListPage(),
      ),
      GoRoute(
        path: '/parent/programs',
        builder: (context, state) => const ParentProgramsListPage(),
      ),
      GoRoute(
        path: '/parent/invitations',
        builder: (context, state) => const ParentInvitationsListPage(),
      ),
      GoRoute(
        path: '/parent/contracts',
        builder: (context, state) => const ParentContractsListPage(),
      ),
    ];
