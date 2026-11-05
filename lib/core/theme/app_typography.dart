import 'package:flutter/material.dart';

import 'app_palette.dart';

/// SOE typography — design system v2 (Studio, "Fondations").
///
/// Two families bundled in `assets/fonts/` (OFL): **Literata** for titles and big numbers,
/// **Figtree** for the interface. Mobile sizes = the Studio "-m" roles (h1 28, h2 24).
/// Mirror of the web `.t-*` classes (`soe/app/javascript/design/tokens.cjs`).
abstract final class AppTypography {
  static const String displayFamily = 'Literata';
  static const String uiFamily = 'Figtree';

  static TextStyle _style(
    String family,
    FontWeight weight,
    double size,
    double lineHeight, {
    double? letterSpacing,
    Color color = AppPalette.text,
  }) {
    return TextStyle(
      fontFamily: family,
      fontWeight: weight,
      fontSize: size,
      height: lineHeight / size,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ── Literata (titles, numbers) ──
  /// Hero of a screen (web h2 size). 32/40.
  static TextStyle get display =>
      _style(displayFamily, FontWeight.w500, 32, 40, color: AppPalette.teal800);

  /// Page title on mobile (Studio h1-m). 28/36.
  static TextStyle get h1 =>
      _style(displayFamily, FontWeight.w500, 28, 36, color: AppPalette.teal800);

  /// Section title on mobile (Studio h2-m). 24/32.
  static TextStyle get h2 =>
      _style(displayFamily, FontWeight.w500, 24, 32, color: AppPalette.teal800);

  /// Card or block title. 20/28.
  static TextStyle get h3 =>
      _style(displayFamily, FontWeight.w500, 20, 28, color: AppPalette.teal800);

  static TextStyle get numberXl =>
      _style(displayFamily, FontWeight.w500, 44, 48, color: AppPalette.teal800);
  static TextStyle get numberL =>
      _style(displayFamily, FontWeight.w500, 32, 38, color: AppPalette.teal800);
  static TextStyle get numberM =>
      _style(displayFamily, FontWeight.w500, 24, 30, color: AppPalette.teal800);

  // ── Figtree (interface) ──
  static TextStyle get title => _style(uiFamily, FontWeight.w600, 18, 24);
  static TextStyle get bodyLg => _style(uiFamily, FontWeight.w400, 17, 26);
  static TextStyle get body => _style(uiFamily, FontWeight.w400, 16, 24);
  static TextStyle get bodySm =>
      _style(uiFamily, FontWeight.w400, 14, 21, color: AppPalette.text2);
  static TextStyle get label => _style(uiFamily, FontWeight.w600, 14, 20);
  static TextStyle get labelSm => _style(uiFamily, FontWeight.w600, 13, 18);
  static TextStyle get caption =>
      _style(uiFamily, FontWeight.w400, 13, 18, color: AppPalette.text2);

  /// Uppercase eyebrow. Apply `.toUpperCase()` to the text.
  static TextStyle get overline => _style(uiFamily, FontWeight.w700, 12, 16,
      letterSpacing: 0.96, color: AppPalette.teal500);

  static TextStyle get buttonLg => _style(uiFamily, FontWeight.w700, 16, 20);
  static TextStyle get button => _style(uiFamily, FontWeight.w600, 15, 20);
  static TextStyle get buttonSm => _style(uiFamily, FontWeight.w600, 14, 18);

  // ── v1 names (kept until every screen is rebuilt; do not use in new code) ──
  static TextStyle get h4 => title;
  static TextStyle get pageTitle => title;
  static TextStyle get subtitle => _style(uiFamily, FontWeight.w600, 16, 24);
}
