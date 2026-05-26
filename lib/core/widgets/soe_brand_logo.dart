import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo SOE — assets officiels téléchargés depuis app.jeteste.site.
///
/// - `onDark: true`  → version monochrome blanche (`logo_white.svg`),
///   à poser directement sur surface marque (teal / gradient).
/// - `onDark: false` → version couleur officielle (`logo_color.svg`).
/// - `variant: SoeBrandLogoVariant.full` → version logo + texte « Solution
///   of Education » (`logo_full.svg`), pour drawer / écrans de marque.
enum SoeBrandLogoVariant { mark, full }

class SoeBrandLogo extends StatelessWidget {
  const SoeBrandLogo({
    super.key,
    this.width = 110,
    this.onDark = false,
    this.variant = SoeBrandLogoVariant.mark,
  });

  final double width;
  final bool onDark;
  final SoeBrandLogoVariant variant;

  static const String _whiteAsset = 'assets/logo/logo_white.svg';
  static const String _colorAsset = 'assets/logo/logo_color.svg';
  static const String _fullAsset = 'assets/logo/logo_full.svg';

  @override
  Widget build(BuildContext context) {
    // `full` garde toujours ses couleurs originales (SOE blanc + O jaune
    // ampoule + sous-titre blanc) — fonctionne sur fond sombre comme clair
    // sans modification.
    final asset = switch (variant) {
      SoeBrandLogoVariant.full => _fullAsset,
      SoeBrandLogoVariant.mark => onDark ? _whiteAsset : _colorAsset,
    };
    return SvgPicture.asset(
      asset,
      width: width,
      semanticsLabel: 'SOE — Solution of Education',
      fit: BoxFit.contain,
    );
  }
}
