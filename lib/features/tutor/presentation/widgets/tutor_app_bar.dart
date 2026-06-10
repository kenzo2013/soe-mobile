import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_palette.dart';

/// AppBar standard du flux tuteur : titre + sous-titre, fond page, cloche
/// optionnelle. Le `leading` est laissé au comportement par défaut du
/// `Scaffold` (burger si un drawer est présent, flèche retour si route poussée).
class TutorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TutorAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBell = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String title;
  final String? subtitle;
  final bool showBell;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final fg = foregroundColor ?? AppPalette.ink;
    final sub = (foregroundColor ?? AppPalette.n700)
        .withValues(alpha: foregroundColor == null ? 1 : 0.7);
    return AppBar(
      backgroundColor: backgroundColor ?? AppPalette.n100,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: fg),
      // iOS centre le titre par défaut — on force l'alignement à gauche.
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: fg,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: TextStyle(color: sub, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      actions: [
        if (showBell)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _BellButton(onDark: foregroundColor != null),
          ),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.onDark});
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.notifications),
      child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: onDark
                ? Colors.white.withValues(alpha: 0.10)
                : AppPalette.white,
            borderRadius: BorderRadius.circular(10),
            border: onDark ? null : Border.all(color: AppPalette.n300),
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 20,
            color: onDark ? Colors.white : AppPalette.ink,
          ),
        ),
        Positioned(
          top: 8,
          right: 9,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppPalette.danger,
              shape: BoxShape.circle,
              border: Border.all(
                color: onDark ? AppPalette.tealDark : AppPalette.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
