import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_radius.dart';

class SoeBottomNavItem {
  const SoeBottomNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Bottom nav SOE (Studio, mobile 390): a white bar with a line on top; the active tab has
/// its icon on a light teal pill and its label in bold teal.
class SoeBottomNav extends StatelessWidget {
  const SoeBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<SoeBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppPalette.white,
        border: Border(top: BorderSide(color: AppPalette.n300)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
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
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? AppPalette.teal100 : Colors.transparent,
                  borderRadius: AppRadius.rLg,
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: active ? AppPalette.teal800 : AppPalette.n500,
                ),
              ),
              const SizedBox(height: 4),
              // One line, shrunk if needed (« Aujourd’hui » in bold).
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppPalette.teal800 : AppPalette.n700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
