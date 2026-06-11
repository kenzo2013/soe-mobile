import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../domain/entities/tutor_payment_method.dart';
import 'pages/tutor_contracts_page.dart';
import 'pages/tutor_courses_pages.dart';
import 'pages/tutor_dashboard_page.dart';
import 'pages/tutor_jobs_pages.dart';
import 'pages/tutor_payment_pages.dart';
import 'pages/tutor_profile_pages.dart';
import 'pages/tutor_remunerations_page.dart';
import 'pages/tutor_sessions_pages.dart';

/// Sous-routes du flux Tuteur. Agrégées par le router racine via
/// `...tutorRoutes()`. **Interdit** de déclarer ces routes ailleurs.
List<RouteBase> tutorRoutes() => [
      // 01 · Tableau de bord
      GoRoute(
        path: RouteNames.tutorDashboard,
        builder: (context, state) => const TutorDashboardPage(),
      ),

      // 02 · Mon profil
      GoRoute(
        path: RouteNames.tutorProfile,
        builder: (context, state) => const TutorProfileHubPage(),
      ),
      GoRoute(
        path: RouteNames.tutorProfileBio,
        builder: (context, state) => const TutorBioPage(),
      ),
      GoRoute(
        path: RouteNames.tutorProfileTrainings,
        builder: (context, state) => const TutorTrainingsPage(),
      ),
      GoRoute(
        path: RouteNames.tutorProfileWorks,
        builder: (context, state) => const TutorWorksPage(),
      ),
      GoRoute(
        path: RouteNames.tutorProfileIdentities,
        builder: (context, state) => const TutorIdentitiesPage(),
      ),
      GoRoute(
        path: RouteNames.tutorProfileCourses,
        builder: (context, state) => const TutorCoursesProfilePage(),
      ),
      GoRoute(
        path: RouteNames.tutorProfileAvailabilities,
        builder: (context, state) => const TutorAvailabilitiesPage(),
      ),

      // 03 · Offres d'emploi
      GoRoute(
        path: RouteNames.tutorJobs,
        builder: (context, state) => const TutorJobsListPage(),
      ),
      GoRoute(
        path: '/tutor/jobs/:id',
        builder: (context, state) =>
            TutorJobDetailPage(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'apply',
            builder: (context, state) =>
                TutorJobApplyPage(id: state.pathParameters['id']!),
          ),
        ],
      ),

      // 04 · Mes cours
      GoRoute(
        path: RouteNames.tutorCourses,
        builder: (context, state) => const TutorActiveCoursesPage(),
      ),
      GoRoute(
        path: '/tutor/courses/:id',
        builder: (context, state) => TutorCourseDetailPage(
          id: state.pathParameters['id']!,
          reservationId: state.uri.queryParameters['reservation_id'],
        ),
        routes: [
          GoRoute(
            path: 'schedules',
            builder: (context, state) =>
                TutorManageSchedulesPage(id: state.pathParameters['id']!),
          ),
        ],
      ),

      // 05 · Séances
      GoRoute(
        path: RouteNames.tutorSessions,
        builder: (context, state) => const TutorSessionsListPage(),
      ),
      GoRoute(
        path: '/tutor/sessions/:id',
        builder: (context, state) =>
            TutorSessionDetailPage(id: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) =>
                TutorSessionEditPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'report',
            builder: (context, state) =>
                TutorSessionReportPage(id: state.pathParameters['id']!),
          ),
        ],
      ),

      // 06 · Rémunérations
      GoRoute(
        path: RouteNames.tutorRemunerations,
        builder: (context, state) => const TutorRemunerationsPage(),
      ),

      // 07 · Infos de paiement
      GoRoute(
        path: RouteNames.tutorPayment,
        builder: (context, state) => const TutorPaymentMethodsPage(),
      ),
      GoRoute(
        path: RouteNames.tutorPaymentAddBank,
        builder: (context, state) =>
            TutorAddBankPage(existing: state.extra as TutorPaymentMethod?),
      ),
      GoRoute(
        path: RouteNames.tutorPaymentDetail,
        builder: (context, state) =>
            TutorPaymentDetailPage(method: state.extra! as TutorPaymentMethod),
      ),

      // 08 · Contrats
      GoRoute(
        path: RouteNames.tutorContracts,
        builder: (context, state) => const TutorContractsPage(),
      ),
    ];
