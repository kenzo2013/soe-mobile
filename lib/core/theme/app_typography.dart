import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Typographie SOE — design system officiel.
///
/// Police : Poppins. Tant qu'elle n'est pas embedée, fallback système.
abstract final class AppTypography {
  static const String fontFamily = 'Poppins';

  // Display 32/40 · 700 · -0.5
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: -0.5,
    color: AppPalette.ink,
  );

  // H1 26/34 · 700 · -0.3
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 26,
    height: 34 / 26,
    letterSpacing: -0.3,
    color: AppPalette.ink,
  );

  // H2 22/30 · 700 · -0.2
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 30 / 22,
    letterSpacing: -0.2,
    color: AppPalette.ink,
  );

  // H3 18/26 · 600 · -0.1
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 26 / 18,
    letterSpacing: -0.1,
    color: AppPalette.ink,
  );

  // H4 16/24 · 600 · 0
  static const TextStyle h4 = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 24 / 16,
    color: AppPalette.ink,
  );

  // Subtitle 15/22 · 600
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 22 / 15,
    color: AppPalette.ink,
  );

  // Body 14/22 · 400
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 22 / 14,
    color: AppPalette.ink,
  );

  // Body small 13/20 · 400
  static const TextStyle bodySm = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 20 / 13,
    color: AppPalette.ink2,
  );

  // Label 12/16 · 500 · 0.2
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.2,
    color: AppPalette.ink2,
  );

  // Caption 11/16 · 400 · 0.1
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.1,
    color: AppPalette.ink2,
  );

  // Overline 11/16 · 700 · 1.0 · UPPER
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 1,
    color: AppPalette.teal,
  );

  // Bouton 14 · 600
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.2,
  );
}
