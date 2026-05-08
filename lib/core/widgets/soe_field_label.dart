import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_typography.dart';

/// Label de champ — 12px, w600, ink. Posé au-dessus de [SoeTextField] /
/// [SoePhoneField] / [SoeCountryField] dans le flow d'inscription.
class SoeFieldLabel extends StatelessWidget {
  const SoeFieldLabel(
    this.text, {
    super.key,
    this.bottom = 6,
  });

  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(
        text,
        style: AppTypography.label.copyWith(
          color: AppPalette.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
