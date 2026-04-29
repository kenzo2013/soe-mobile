import 'package:flutter/material.dart';

/// Palette SOE — cahier des charges §2.1.
abstract final class AppPalette {
  // Marque
  static const Color primary = Color(0xFFFFB000); // Or
  static const Color secondary = Color(0xFF035E7B); // Bleu-vert

  // Texte
  static const Color textPrimary = Color(0xFF010814);
  static const Color textSecondary = Color(0xFF526684);
  static const Color textTertiary = Color(0xFFA3BCE2);

  // Fonds
  static const Color surface = Color(0xFFFCFDFF);
  static const Color surfaceLight = Color(0xFFF5F9FF);
  static const Color surfaceAccent = Color(0xFFDCEAFF);
  static const Color background = Color(0xFFEAF0F9);

  // Sémantique
  static const Color success = Color(0xFF028226);
  static const Color error = Color(0xFFFF3F3F);
  static const Color warning = Color(0xFFFF7A00);
}
