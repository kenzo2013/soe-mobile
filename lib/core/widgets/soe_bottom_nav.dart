import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_palette.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

class SoeBottomNavItem {
  const SoeBottomNavItem(
      {required this.icon, required this.label, this.activeIcon});
  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

/// The navigation of a phone (colourful direction): a floating navy pill (radius 34, height
/// 68) 14 px from the sides and 20 px above the safe area, with a soft shadow. Inactive tabs
/// are icons (#C5D8E6); the active tab is a translucent grey pill with its white icon and
/// label. The content scrolls behind it.
class SoeBottomNav extends StatelessWidget {
  const SoeBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const double height = 68;

  /// Room the pill takes above the safe area (height + bottom margin + a gap).
  static const double clearance = height + 20 + 12;

  final List<SoeBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 20 + bottom),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          color: AppPalette.navy,
          borderRadius: BorderRadius.all(Radius.circular(34)),
          boxShadow: AppShadows.nav,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (int i = 0; i < items.length; i++)
              _NavTile(
                item: items[i],
                active: i == currentIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final SoeBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final tile = AnimatedContainer(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: 46,
      constraints: const BoxConstraints(minWidth: 46),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: active ? AppPalette.onBandActive : Colors.transparent,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: active ? 14 : 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? (item.activeIcon ?? item.icon) : item.icon,
                size: active ? 20 : 22,
                color: active ? AppPalette.white : AppPalette.navInactive),
            if (active) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: AppTypography.labelSm.copyWith(
                      fontWeight: FontWeight.w700, color: AppPalette.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return Flexible(
      flex: active ? 3 : 1,
      child: Semantics(
        selected: active,
        button: true,
        label: item.label,
        excludeSemantics: true,
        child: Tooltip(
          message: item.label,
          excludeFromSemantics: true,
          child: InkResponse(
            onTap: onTap,
            radius: 28,
            highlightShape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(23),
            child: Center(child: tile),
          ),
        ),
      ),
    );
  }
}

/// The navigation of a tablet: a floating navy rail on the left (radius 34), the white logo
/// on top, the tabs below with the same translucent grey pill for the active one.
class SoeNavRail extends StatelessWidget {
  const SoeNavRail({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  static const double width = 96;

  final List<SoeBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          14 + padding.left, padding.top + 14, 0, padding.bottom + 14),
      child: Container(
        key: const Key('space-rail'),
        width: width,
        decoration: const BoxDecoration(
          color: AppPalette.navy,
          borderRadius: BorderRadius.all(Radius.circular(34)),
          boxShadow: AppShadows.nav,
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 26),
          Center(
            child: SvgPicture.asset('assets/logo/logo_white.svg',
                width: 54, semanticsLabel: 'SOE — Solution of Education'),
          ),
          const SizedBox(height: 28),
          for (int i = 0; i < items.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: _RailTile(
                item: items[i],
                active: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
        ]),
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile(
      {required this.item, required this.active, required this.onTap});

  final SoeBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: active,
        button: true,
        label: item.label,
        excludeSemantics: true,
        child: Material(
          color: active ? AppPalette.onBandActive : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Column(children: [
                Icon(active ? (item.activeIcon ?? item.icon) : item.icon,
                    size: 22,
                    color: active ? AppPalette.white : AppPalette.navInactive),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(item.label,
                      maxLines: 1,
                      style: AppTypography.labelSm.copyWith(
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w600,
                          color: active
                              ? AppPalette.white
                              : AppPalette.navInactive)),
                ),
              ]),
            ),
          ),
        ),
      );
}
