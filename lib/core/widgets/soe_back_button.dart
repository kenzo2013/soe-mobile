import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Bouton retour SOE — 40×40, fond n100, radius 12, chevron gauche.
///
/// Design system officiel (cf. auth artboards). À utiliser comme `leading`
/// d'un `SoeAppBar` ou en haut d'un layout sans AppBar.
class SoeBackButton extends StatelessWidget {
  const SoeBackButton({super.key, this.onPressed, this.tooltip});

  /// Si null, fait `Navigator.maybePop(context)`.
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.n100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.chevron_left,
              size: 22,
              color: AppPalette.ink,
            ),
          ),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}
