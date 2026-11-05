import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../i18n/translations.g.dart';
import '../../parent_space/presentation/pages/parent_children_page.dart';
import '../../parent_space/presentation/pages/parent_home_page.dart';
import '../../parent_space/presentation/pages/parent_payments_page.dart';
import '../../parent_space/presentation/pages/parent_planning_page.dart';
import '../../tutor_space/presentation/pages/tutor_earnings_page.dart';
import '../../tutor_space/presentation/pages/tutor_home_page.dart';
import '../../tutor_space/presentation/pages/tutor_planning_page.dart';
import '../../tutor_space/presentation/pages/tutor_student_pages.dart';
import '../../parent_space/presentation/parent_space_router.dart';
import '../../tutor_space/presentation/providers.dart';
import '../../tutor_space/presentation/tutor_space_router.dart';
import 'pages/more_page.dart';
import 'widgets/role_shell.dart';

/// The two signed-in spaces and their tabs (Q5). The parent tabs hold the v2 screens (lot 3),
/// the tutor tabs those of lot 4 (REP-01: Aujourd’hui, Planning, Élèves, Revenus,
/// Plus; a candidate: Dossier, Offres, Candidatures, Plus). The detail screens of Planning,
/// Enfants (Élèves), Paiements (Revenus) and the screens of « Plus » stay under the tab bar;
/// the flows with their own bottom action are full screen.
List<RouteBase> shellRoutes() => [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) {
          final tr = Translations.of(context).shell;
          return RoleShell(
              navigationShell: shell,
              tabForLocation: (location) =>
                  tabOfScreen(location, parentTabScreens, only: 4),
              tabs: [
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
          _branch(RouteNames.parentHome, const ParentHomePage()),
          _branch(RouteNames.parentPlanning, const ParentPlanningPage(),
              screens: parentTabRoutes(1)),
          _branch(RouteNames.parentChildren, const ParentChildrenPage(),
              screens: parentTabRoutes(2)),
          _branch(RouteNames.parentPayments, const ParentPaymentsPage(),
              screens: parentTabRoutes(3)),
          _branch(RouteNames.parentMore, const MorePage(),
              screens: parentTabRoutes(4)),
        ],
      ),
      StatefulShellRoute.indexedStack(
        // A candidate (REP-01 « Mode recrutement ») sees Dossier · Offres · Candidatures · Plus;
        // an active tutor Aujourd’hui · Planning · Élèves · Revenus · Plus. One shell, whose
        // extra branches (5 Offres, 6 Candidatures) only a candidate's tabs open.
        builder: (context, state, shell) => Consumer(
          builder: (context, ref, _) {
            final tr = Translations.of(context).shell;
            final candidate = ref.watch(tutorCandidateProvider);
            return RoleShell(
                navigationShell: shell,
                tabForLocation: (location) =>
                    tutorTabOfLocation(location, candidate: candidate),
                tabs: tutorShellTabs(tr, candidate: candidate));
          },
        ),
        branches: [
          // Tutor space v2 (lot 4, API v2).
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.tutorHome,
              builder: (context, state) => const TutorHomePage(),
              routes: [tutorCandidateFileRoute()],
            ),
          ]),
          _branch(RouteNames.tutorPlanning, const TutorPlanningPage(),
              screens: tutorTabRoutes(1)),
          _branch(RouteNames.tutorStudents, const TutorStudentsPage(),
              screens: tutorTabRoutes(2)),
          _branch(RouteNames.tutorEarnings, const TutorEarningsPage(),
              screens: tutorTabRoutes(3)),
          _branch(RouteNames.tutorMore, const MorePage(),
              screens: tutorTabRoutes(4)),
          StatefulShellBranch(routes: tutorCandidateOffersRoutes()),
          StatefulShellBranch(routes: tutorCandidateApplicationsRoutes()),
        ],
      ),
    ];

/// The tab of a screen of [screens] (path patterns with `:id`) when it is [only]; null else.
int? tabOfScreen(String location, Map<String, int> screens,
    {required int only}) {
  for (final MapEntry(key: pattern, value: tab) in screens.entries) {
    if (tab != only) continue;
    final regex = RegExp(
        '^${pattern.split('/').map((part) => part.startsWith(':') ? '[^/]+' : RegExp.escape(part)).join('/')}\$');
    if (regex.hasMatch(location)) return tab;
  }
  return null;
}

/// The tab a tutor screen belongs to: for a candidate, an offer under « Offres » (1), the
/// applications under « Candidatures » (2), the file under « Dossier » (0); for an active tutor,
/// the screens of « Plus » (4).
int? tutorTabOfLocation(String location, {required bool candidate}) {
  if (!candidate) return tabOfScreen(location, tutorTabScreens, only: 4);
  if (location.startsWith(RouteNames.tutorCandidateOffers)) return 1;
  if (location.startsWith(RouteNames.tutorCandidateApplications)) return 2;
  if (location.startsWith(RouteNames.tutorCandidateFile)) return 0;
  return null;
}

/// The tutor's tabs; a candidate's (REP-01 « Mode recrutement ») when [candidate].
List<ShellTab> tutorShellTabs(TranslationsShellFr tr,
        {required bool candidate}) =>
    candidate ? _candidateTabs(tr) : _activeTabs(tr);

List<ShellTab> _activeTabs(TranslationsShellFr tr) => [
      ShellTab(
          icon: Icons.today_outlined,
          activeIcon: Icons.today,
          label: tr.tutor.today),
      ShellTab(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today,
          label: tr.tutor.planning),
      ShellTab(
          icon: Icons.groups_outlined,
          activeIcon: Icons.groups,
          label: tr.tutor.students),
      ShellTab(
          icon: Icons.payments_outlined,
          activeIcon: Icons.payments,
          label: tr.tutor.earnings),
      ShellTab(
          icon: Icons.menu,
          activeIcon: Icons.menu_open,
          label: tr.more.tab,
          branches: const [4, 5, 6]),
    ];

/// A candidate's tabs: « Dossier » is the home (branch 0, the file under it), then the offers
/// (5), the applications (6), « Plus » (4).
List<ShellTab> _candidateTabs(TranslationsShellFr tr) => [
      ShellTab(
          icon: Icons.badge_outlined,
          activeIcon: Icons.badge,
          label: tr.tutor.file),
      ShellTab(
          icon: Icons.work_outline,
          activeIcon: Icons.work,
          label: tr.tutor.offers,
          branches: const [5]),
      ShellTab(
          icon: Icons.insert_drive_file_outlined,
          activeIcon: Icons.insert_drive_file,
          label: tr.tutor.applications,
          branches: const [6]),
      ShellTab(
          icon: Icons.menu,
          activeIcon: Icons.menu_open,
          label: tr.more.tab,
          branches: const [4, 1, 2, 3]),
    ];

/// A tab: its first screen, then the detail screens it shows under its tab bar.
StatefulShellBranch _branch(String path, Widget page,
        {List<RouteBase> screens = const []}) =>
    StatefulShellBranch(
      routes: [
        GoRoute(path: path, builder: (context, state) => page),
        ...screens,
      ],
    );
