import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';
import 'soe_back_button.dart';

/// AppBar SOE — fond transparent par défaut (hérite du Scaffold) ou marque (teal).
///
/// `leading` par défaut : `SoeBackButton` si la route peut pop. Désactiver via
/// `automaticallyImplyLeading: false`.
class SoeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SoeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.brand = false,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  /// `true` → surface marque (teal, texte blanc).
  final bool brand;

  /// `null` (défaut) → transparent (le Scaffold montre sa propre couleur).
  final Color? backgroundColor;

  /// Si false, ne génère pas de bouton retour automatique.
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final fg = brand ? AppPalette.white : AppPalette.ink;
    final bg =
        brand ? AppPalette.teal : (backgroundColor ?? Colors.transparent);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final autoLeading =
        leading == null && automaticallyImplyLeading && canPop && !brand
            ? const SoeBackButton()
            : leading;

    return AppBar(
      backgroundColor: bg,
      foregroundColor: fg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: autoLeading,
      automaticallyImplyLeading: false,
      titleSpacing: autoLeading == null ? 24 : 8,
      title: Text(title, style: AppTypography.h3.copyWith(color: fg)),
      actions: actions,
      systemOverlayStyle:
          brand ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    );
  }
}
