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
      {required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The frame of a signed-in space (Q5): a tab bar of 4 tabs + « Plus » on a phone, a
/// rail on a tablet. Each tab keeps its own history (go_router branches). On a phone, « Plus »
/// (the last tab) opens its menu as a sheet over the open tab.
class RoleShell extends ConsumerWidget {
  const RoleShell(
      {super.key, required this.navigationShell, required this.tabs});

  /// The rail needs a tablet (shortest side), not a phone turned sideways.
  static const double railShortestSide = 600;

  final StatefulNavigationShell navigationShell;
  final List<ShellTab> tabs;

  /// A tap on the open tab brings it back to its first screen.
  void _open(int index) => navigationShell.goBranch(index,
      initialLocation: index == navigationShell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablet = MediaQuery.sizeOf(context).shortestSide >= railShortestSide;
    if (!tablet) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: SoeBottomNav(
          items: [
            for (final tab in tabs)
              SoeBottomNavItem(icon: tab.icon, label: tab.label)
          ],
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            if (index == tabs.length - 1) {
              unawaited(showMoreSheet(context, ref));
            } else {
              _open(index);
            }
          },
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _open,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppPalette.white,
              indicatorColor: AppPalette.infoBg,
              selectedIconTheme: const IconThemeData(color: AppPalette.teal),
              unselectedIconTheme: const IconThemeData(color: AppPalette.n500),
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
          const VerticalDivider(width: 1, color: AppPalette.n300),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
