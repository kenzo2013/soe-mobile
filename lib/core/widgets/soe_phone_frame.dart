import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Surface marque (bleu-vert dégradé) — utilisée en haut des écrans onboarding,
/// auth, splash. Texte blanc par défaut.
class SoeBrandSurface extends StatelessWidget {
  const SoeBrandSurface({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: const BoxDecoration(gradient: AppPalette.brandGradient),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppPalette.white),
        child: child,
      ),
    );
  }
}

/// Page-surface neutre (n100) — wrapper standard.
class SoePageBackground extends StatelessWidget {
  const SoePageBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppPalette.n100, child: child);
  }
}
