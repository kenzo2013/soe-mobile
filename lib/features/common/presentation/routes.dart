import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/account_address_page.dart';
import 'pages/account_hub_page.dart';
import 'pages/account_notification_prefs_page.dart';
import 'pages/account_personal_info_page.dart';
import 'pages/account_roles_page.dart';
import 'pages/account_security_page.dart';
import 'pages/help_page.dart';
import 'pages/notifications_center_page.dart';
import 'pages/report_pages.dart';

/// Routes of the account and common screens (COM-01 to COM-10), aggregated by the root router
/// through `...commonRoutes()`. They open full screen, over the tabs.
List<RouteBase> commonRoutes() => [
      GoRoute(
        path: RouteNames.account,
        builder: (context, state) => const AccountHubPage(),
      ),
      GoRoute(
        path: RouteNames.accountProfile,
        builder: (context, state) => const AccountPersonalInfoPage(),
      ),
      GoRoute(
        path: RouteNames.accountSecurity,
        builder: (context, state) => const AccountSecurityPage(),
      ),
      GoRoute(
        path: RouteNames.accountDeletion,
        builder: (context, state) => const AccountDeletionPage(),
      ),
      GoRoute(
        path: RouteNames.accountAddress,
        builder: (context, state) => const AccountAddressPage(),
      ),
      GoRoute(
        path: RouteNames.accountRoles,
        builder: (context, state) => const AccountRolesPage(),
      ),
      GoRoute(
        path: RouteNames.accountNotificationPrefs,
        builder: (context, state) => const AccountNotificationPrefsPage(),
      ),
      GoRoute(
        path: RouteNames.help,
        builder: (context, state) => const HelpPage(),
      ),
      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => const ReportsPage(),
      ),
      // `?session_id=` prefills the session; `?serious=1` opens the emergency way.
      GoRoute(
        path: RouteNames.reportNew,
        builder: (context, state) => ReportProblemPage(
          sessionId:
              int.tryParse(state.uri.queryParameters['session_id'] ?? ''),
          serious: state.uri.queryParameters['serious'] == '1',
        ),
      ),
      GoRoute(
        path: '${RouteNames.reports}/:id',
        builder: (context, state) => ReportDetailPage(
            reportId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsCenterPage(),
      ),
    ];
