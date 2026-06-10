import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_palette.dart';

/// Barre supérieure des écrans communs — calquée sur la `TopBar` du design
/// (`common.jsx`) : flèche retour, titre + sous-titre alignés à gauche, action
/// optionnelle à droite. Fond page (n100).
class CommonTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    return AppBar(
      backgroundColor: AppPalette.n100,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      leadingWidth: canPop ? 52 : 16,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Material(
                color: AppPalette.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppPalette.n300),
                    ),
                    child: const Icon(Icons.chevron_left,
                        size: 22, color: AppPalette.ink),
                  ),
                ),
              ),
            )
          : const SizedBox(width: 16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppPalette.ink,
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
                style: const TextStyle(color: AppPalette.n700, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      actions: [
        if (action != null)
          Padding(padding: const EdgeInsets.only(right: 16), child: action!),
      ],
    );
  }
}
