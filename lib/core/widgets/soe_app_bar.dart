import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// AppBar SOE — fond page (n100) ou marque (teal).
class SoeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SoeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.brand = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  /// `true` → surface marque (teal, texte blanc).
  final bool brand;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final fg = brand ? AppPalette.white : AppPalette.ink;
    return AppBar(
      backgroundColor: brand ? AppPalette.teal : AppPalette.n100,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: leading,
      titleSpacing: leading == null ? 24 : 0,
      title: Text(title, style: AppTypography.h3.copyWith(color: fg)),
      actions: actions,
      systemOverlayStyle:
          brand ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}
