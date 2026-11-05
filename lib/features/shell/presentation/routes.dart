import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../i18n/translations.g.dart';
import '../../parent_space/presentation/pages/parent_children_page.dart';
import '../../parent_space/presentation/pages/parent_home_page.dart';
import '../../parent_space/presentation/pages/parent_payments_page.dart';
import '../../parent_space/presentation/pages/parent_planning_page.dart';
import '../../tutor_space/presentation/pages/tutor_contract_pages.dart';
import '../../tutor_space/presentation/pages/tutor_earnings_page.dart';
import '../../tutor_space/presentation/pages/tutor_home_page.dart';
import '../../tutor_space/presentation/pages/tutor_planning_page.dart';
import 'pages/more_page.dart';
import 'widgets/role_shell.dart';

/// The two signed-in spaces and their tabs (Q5). The parent tabs hold the v2 screens (lot 3),
/// the tutor tabs those of lot 4. Screens opened from a tab are full screen.
List<RouteBase> shellRoutes() => [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          final tr = Translations.of(context).shell;
          return RoleShell(navigationShell: shell, tabs: [
            ShellTab(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: tr.parent.home),
            ShellTab(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: tr.parent.planning),
            ShellTab(
                icon: Icons.family_restroom_outlined,
                activeIcon: Icons.family_restroom,
                label: tr.parent.children),
            ShellTab(
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: tr.parent.payments),
            ShellTab(
                icon: Icons.menu,
                activeIcon: Icons.menu_open,
                label: tr.more.tab),
          ]);
        },
        branches: [
          // Parent space v2 (lot 3, API v2).
          _branch(RouteNames.parentDashboard, const ParentHomePage()),
          _branch(RouteNames.parentSessions, const ParentPlanningPage()),
          _branch(RouteNames.parentStudents, const ParentChildrenPage()),
          _branch(RouteNames.parentPayments, const ParentPaymentsPage()),
          _branch(RouteNames.parentMore, const MorePage()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          final tr = Translations.of(context).shell;
          return RoleShell(navigationShell: shell, tabs: [
            ShellTab(
                icon: Icons.today_outlined,
                activeIcon: Icons.today,
                label: tr.tutor.today),
            ShellTab(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: tr.tutor.planning),
            ShellTab(
                icon: Icons.description_outlined,
                activeIcon: Icons.description,
                label: tr.tutor.contracts),
            ShellTab(
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments,
                label: tr.tutor.earnings),
            ShellTab(
                icon: Icons.menu,
                activeIcon: Icons.menu_open,
                label: tr.more.tab),
          ]);
        },
        branches: [
          // Tutor space v2 (lot 4, API v2).
          _branch(RouteNames.tutorDashboard, const TutorHomePage()),
          _branch(RouteNames.tutorSessions, const TutorPlanningPage()),
          _branch(RouteNames.tutorCourses, const TutorContractsPage()),
          _branch(RouteNames.tutorRemunerations, const TutorEarningsPage()),
          _branch(RouteNames.tutorMore, const MorePage()),
        ],
      ),
    ];

StatefulShellBranch _branch(String path, Widget page) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => page)],
    );
