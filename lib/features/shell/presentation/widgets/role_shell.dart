import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/soe_bottom_nav.dart';
import 'more_sheet.dart';

/// One tab of a role's space.
class ShellTab {
  const ShellTab(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      this.branches = const []});

  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// The branches the tab stands for, the first one opened by a tap; empty: the branch of the
  /// tab's own index. « Plus » stands for the screens it opens (REP-01 candidate: Offres is
  /// branch 5).
  final List<int> branches;
}

/// The frame of a signed-in space (Q5): a tab bar of 4 tabs + « Plus » on a phone, a
/// rail on a tablet. Each tab keeps its own history (go_router branches). On a phone, « Plus »
/// (the last tab) opens its menu as a sheet over the open tab.
class RoleShell extends ConsumerWidget {
  const RoleShell(
      {super.key,
      required this.navigationShell,
      required this.tabs,
      this.tabForLocation});

  /// The rail needs a tablet (shortest side), not a phone turned sideways.
  static const double railShortestSide = 600;

  final StatefulNavigationShell navigationShell;
  final List<ShellTab> tabs;

  /// The tab a screen belongs to, whatever tab opened it (a screen of « Plus » pushed from
  /// the home lights « Plus », as in the Studio); null: the tab of the open branch.
  final int? Function(String location)? tabForLocation;

  int _branchOf(int tab) =>
      tabs[tab].branches.isEmpty ? tab : tabs[tab].branches.first;

  /// The tab of the screen on top, else of the open branch (« Plus » when no tab claims it).
  int _currentTab(BuildContext context) {
    // The screen on top, a pushed one included (`uri` keeps the location below it).
    final matches =
        GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration;
    final location = matches == null || matches.isEmpty
        ? null
        : matches.last.matchedLocation;
    final tab = location == null ? null : tabForLocation?.call(location);
    if (tab != null && tab < tabs.length) return tab;
    final branch = navigationShell.currentIndex;
    for (var i = 0; i < tabs.length; i++) {
      final branches = tabs[i].branches;
      if (branches.isEmpty ? i == branch : branches.contains(branch)) return i;
    }
    return tabs.length - 1;
  }

  /// A tap on the open tab brings it back to its first screen.
  void _open(int tab) {
    final branch = _branchOf(tab);
    navigationShell.goBranch(branch,
        initialLocation: branch == navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= railShortestSide;
    if (!tablet) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: _OnNavigation(
          builder: (context) => SoeBottomNav(
            items: [
              for (final tab in tabs)
                SoeBottomNavItem(icon: tab.icon, label: tab.label)
            ],
            currentIndex: _currentTab(context),
            onTap: (index) {
              if (index == tabs.length - 1) {
                unawaited(showMoreSheet(context, ref));
              } else {
                _open(index);
              }
            },
          ),
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: _OnNavigation(
              builder: (context) => NavigationRail(
                selectedIndex: _currentTab(context),
                onDestinationSelected: _open,
                labelType: NavigationRailLabelType.all,
                backgroundColor: AppPalette.white,
                indicatorColor: AppPalette.infoBg,
                selectedIconTheme: const IconThemeData(color: AppPalette.teal),
                unselectedIconTheme:
                    const IconThemeData(color: AppPalette.n500),
                selectedLabelTextStyle:
                    AppTypography.labelSm.copyWith(color: AppPalette.teal),
                unselectedLabelTextStyle:
                    AppTypography.labelSm.copyWith(color: AppPalette.n700),
                destinations: [
                  for (final tab in tabs)
                    NavigationRailDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.activeIcon),
                      label: Text(tab.label),
                    ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: AppPalette.n300),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

/// Rebuilds on each navigation: a screen pushed inside a tab does not rebuild the shell, and
/// the tab it belongs to may differ from the open one.
class _OnNavigation extends StatelessWidget {
  const _OnNavigation({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return builder(context);
    return ListenableBuilder(
        listenable: router.routerDelegate,
        builder: (context, _) => builder(context));
  }
}
