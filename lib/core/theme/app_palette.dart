import 'package:flutter/material.dart';

/// Palette SOE — design system officiel + cahier des charges §2.1.
abstract final class AppPalette {
  // Marque
  static const Color teal = Color(0xFF035E7B); // headers, brand
  static const Color tealDeep = Color(0xFF024A62); // pressed
  static const Color tealDark = Color(0xFF01324A); // gradient end
  static const Color yellow = Color(0xFFFFB000); // CTA principal
  static const Color yellowDeep = Color(0xFFE59E00); // pressed

  // Texte / encres
  static const Color ink = Color(0xFF010814); // textPrimary
  static const Color ink2 = Color(0xFF526684); // textSecondary
  static const Color ink3 = Color(0xFFA3BCE2); // textTertiary / placeholders

  // Neutrals (4px-grid)
  static const Color n900 = Color(0xFF010814);
  static const Color n700 = Color(0xFF526684);
  static const Color n500 = Color(0xFFA3BCE2);
  static const Color n300 = Color(0xFFDCEAFF); // fond accent / borders légers
  static const Color n100 = Color(0xFFEAF0F9); // fond page
  static const Color n50 = Color(0xFFF5F9FF); // fond clair
  static const Color white = Color(0xFFFCFDFF); // surface

  // Sémantique
  static const Color success = Color(0xFF028226);
  static const Color successBg = Color(0xFFE6F5EA);
  static const Color warning = Color(0xFFFF7A00);
  static const Color warningBg = Color(0xFFFFEEDD);
  static const Color danger = Color(0xFFFF3F3F);
  static const Color dangerBg = Color(0xFFFFE6E6);
  static const Color info = Color(0xFF035E7B);
  static const Color infoBg = Color(0xFFDCEAFF);

  // Aliases historiques (rétrocompat)
  static const Color primary = yellow;
  static const Color secondary = teal;
  static const Color textPrimary = ink;
  static const Color textSecondary = ink2;
  static const Color textTertiary = ink3;
  static const Color surface = white;
  static const Color surfaceLight = n50;
  static const Color surfaceAccent = n300;
  static const Color background = n100;
  static const Color error = danger;

  // Gradient marque (ink → teal)
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.55, 1],
    colors: [ink, tealDark, teal],
  );
}
