import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../i18n/translations.g.dart';
import '../../parent/presentation/pages/parent_children_list_page.dart';
import '../../parent/presentation/pages/parent_dashboard_page.dart';
import '../../parent/presentation/pages/parent_payments_list_page.dart';
import '../../parent/presentation/pages/parent_sessions_list_page.dart';
import '../../tutor/presentation/pages/tutor_courses_pages.dart';
import '../../tutor/presentation/pages/tutor_dashboard_page.dart';
import '../../tutor/presentation/pages/tutor_remunerations_page.dart';
import '../../tutor/presentation/pages/tutor_sessions_pages.dart';
import 'pages/more_page.dart';
import 'widgets/role_shell.dart';

/// The two signed-in spaces and their tabs (Q5). Until lots 3 and 4 rebuild them, the
/// tabs hold the current screens; the screens that open from a tab stay full screen.
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
          _branch(RouteNames.parentDashboard, const ParentDashboardPage()),
          _branch(RouteNames.parentSessions, const ParentSessionsListPage()),
          _branch(RouteNames.parentStudents, const ParentChildrenListPage()),
          _branch(RouteNames.parentPayments, const ParentPaymentsListPage()),
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
                icon: Icons.school_outlined,
                activeIcon: Icons.school,
                label: tr.tutor.students),
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
          _branch(RouteNames.tutorDashboard, const TutorDashboardPage()),
          _branch(RouteNames.tutorSessions, const TutorSessionsListPage()),
          _branch(RouteNames.tutorCourses, const TutorActiveCoursesPage()),
          _branch(
              RouteNames.tutorRemunerations, const TutorRemunerationsPage()),
          _branch(RouteNames.tutorMore, const MorePage()),
        ],
      ),
    ];

StatefulShellBranch _branch(String path, Widget page) => StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, state) => page)],
    );
