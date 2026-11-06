import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/soe_bottom_nav.dart';
import '../../../common/presentation/widgets/push_gate.dart';
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

/// The frame of a signed-in space (Q5): a floating navy pill of 4 tabs + « Plus » on a
/// phone, a floating navy rail on the left on a tablet. Each tab keeps its own history (go_router branches). On a phone, « Plus »
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
  Widget build(BuildContext context, WidgetRef ref) =>
      PushGate(child: _frame(context, ref));

  Widget _frame(BuildContext context, WidgetRef ref) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= railShortestSide;
    final items = [
      for (final tab in tabs)
        SoeBottomNavItem(
            icon: tab.icon, activeIcon: tab.activeIcon, label: tab.label)
    ];
    if (!tablet) {
      final media = MediaQuery.of(context);
      return Scaffold(
        backgroundColor: AppPalette.surfacePage,
        // The floating pill lies over the content, which scrolls behind it: the screens get
        // the pill's room as their bottom padding.
        body: Stack(children: [
          MediaQuery(
            data: media.copyWith(
                padding: media.padding.copyWith(
                    bottom: media.padding.bottom + SoeBottomNav.clearance)),
            child: navigationShell,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _OnNavigation(
              builder: (context) => SoeBottomNav(
                items: items,
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
          ),
        ]),
      );
    }
    final media = MediaQuery.of(context);
    const railRoom = SoeNavRail.width + 14;
    return Scaffold(
      backgroundColor: AppPalette.surfacePage,
      body: Stack(children: [
        // The screens start right of the floating rail; their bands run under it.
        MediaQuery(
          data: media.copyWith(padding: media.padding.copyWith(left: 0)),
          child: Padding(
            padding: EdgeInsets.only(left: railRoom + media.padding.left),
            child: navigationShell,
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: _OnNavigation(
            builder: (context) => SoeNavRail(
              items: items,
              currentIndex: _currentTab(context),
              onTap: _open,
            ),
          ),
        ),
      ]),
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
