import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Typographie SOE — design system officiel.
///
/// Police : Poppins via `google_fonts` (téléchargée et cachée localement au
/// premier run). Les styles ne sont plus `const` car ils résolvent dynamiquement
/// le `fontFamily` au runtime, mais ils restent stables (mêmes objets après
/// le premier appel grâce au cache de google_fonts).
abstract final class AppTypography {
  static const String fontFamily = 'Poppins';

  static TextStyle _poppins({
    required FontWeight weight,
    required double size,
    required double height,
    double? letterSpacing,
    Color color = AppPalette.ink,
  }) {
    return GoogleFonts.poppins(
      fontWeight: weight,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // Display 32/40 · 700 · -0.5
  static TextStyle get display => _poppins(
        weight: FontWeight.w700,
        size: 32,
        height: 40 / 32,
        letterSpacing: -0.5,
      );

  // H1 26/34 · 700 · -0.3
  static TextStyle get h1 => _poppins(
        weight: FontWeight.w700,
        size: 26,
        height: 34 / 26,
        letterSpacing: -0.3,
      );

  // H2 22/30 · 700 · -0.2
  static TextStyle get h2 => _poppins(
        weight: FontWeight.w700,
        size: 22,
        height: 30 / 22,
        letterSpacing: -0.2,
      );

  // H3 18/26 · 600 · -0.1
  static TextStyle get h3 => _poppins(
        weight: FontWeight.w600,
        size: 18,
        height: 26 / 18,
        letterSpacing: -0.1,
      );

  // H4 16/24 · 600 · 0
  static TextStyle get h4 => _poppins(
        weight: FontWeight.w600,
        size: 16,
        height: 24 / 16,
      );

  // Subtitle 15/22 · 600
  static TextStyle get subtitle => _poppins(
        weight: FontWeight.w600,
        size: 15,
        height: 22 / 15,
      );

  // Body 14/22 · 400
  static TextStyle get body => _poppins(
        weight: FontWeight.w400,
        size: 14,
        height: 22 / 14,
      );

  // Body small 13/20 · 400
  static TextStyle get bodySm => _poppins(
        weight: FontWeight.w400,
        size: 13,
        height: 20 / 13,
        color: AppPalette.ink2,
      );

  // Label 12/16 · 500 · 0.2
  static TextStyle get label => _poppins(
        weight: FontWeight.w500,
        size: 12,
        height: 16 / 12,
        letterSpacing: 0.2,
        color: AppPalette.ink2,
      );

  // Caption 11/16 · 400 · 0.1
  static TextStyle get caption => _poppins(
        weight: FontWeight.w400,
        size: 11,
        height: 16 / 11,
        letterSpacing: 0.1,
        color: AppPalette.ink2,
      );

  // Overline 11/16 · 700 · 1.0 · UPPER
  static TextStyle get overline => _poppins(
        weight: FontWeight.w700,
        size: 11,
        height: 16 / 11,
        letterSpacing: 1,
        color: AppPalette.teal,
      );

  // Bouton 14 · 600
  static TextStyle get button => _poppins(
        weight: FontWeight.w600,
        size: 14,
        height: 1.2,
      );
}
