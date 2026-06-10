import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../domain/entities/app_notification.dart';
import '../domain/entities/service_contract.dart';
import 'pages/account_address_page.dart';
import 'pages/account_hub_page.dart';
import 'pages/account_notification_prefs_page.dart';
import 'pages/account_password_page.dart';
import 'pages/account_personal_info_page.dart';
import 'pages/account_role_page.dart';
import 'pages/contract_detail_page.dart';
import 'pages/notification_detail_page.dart';
import 'pages/notifications_center_page.dart';

/// Sous-routes des écrans communs (CDC §6). Agrégées par le router racine via
/// `...commonRoutes()`. **Interdit** de déclarer ces routes ailleurs.
List<RouteBase> commonRoutes() => [
      // Mon compte
      GoRoute(
        path: RouteNames.account,
        builder: (context, state) => const AccountHubPage(),
      ),
      GoRoute(
        path: RouteNames.accountProfile,
        builder: (context, state) => const AccountPersonalInfoPage(),
      ),
      GoRoute(
        path: RouteNames.accountPassword,
        builder: (context, state) => const AccountPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.accountAddress,
        builder: (context, state) => const AccountAddressPage(),
      ),
      GoRoute(
        path: RouteNames.accountRole,
        builder: (context, state) => const AccountRolePage(),
      ),
      GoRoute(
        path: RouteNames.accountNotificationPrefs,
        builder: (context, state) => const AccountNotificationPrefsPage(),
      ),

      // Contrat — détail (partagé parent + tuteur), via state.extra
      GoRoute(
        path: RouteNames.contractDetail,
        builder: (context, state) =>
            ContractDetailPage(contract: state.extra! as ServiceContract),
      ),

      // Notifications
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsCenterPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) => NotificationDetailPage(
              notification: state.extra as AppNotification?,
            ),
          ),
        ],
      ),
    ];
