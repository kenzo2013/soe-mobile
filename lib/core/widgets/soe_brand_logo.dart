import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo SOE — assets officiels téléchargés depuis app.jeteste.site.
///
/// - `onDark: true`  → version monochrome blanche (`assets/logo/logo_white.svg`),
///   à poser directement sur surface marque (teal / gradient).
/// - `onDark: false` → version couleur officielle (`assets/logo/logo_color.svg`),
///   pour fonds clairs.
class SoeBrandLogo extends StatelessWidget {
  const SoeBrandLogo({super.key, this.width = 110, this.onDark = false});

  final double width;
  final bool onDark;

  static const String _whiteAsset = 'assets/logo/logo_white.svg';
  static const String _colorAsset = 'assets/logo/logo_color.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      onDark ? _whiteAsset : _colorAsset,
      width: width,
      semanticsLabel: 'SOE — Solution of Education',
      fit: BoxFit.contain,
    );
  }
}
