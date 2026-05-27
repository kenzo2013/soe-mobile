import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.teal,
      primary: AppPalette.yellow,
      secondary: AppPalette.teal,
      error: AppPalette.danger,
      surface: AppPalette.white,
    );

    // Poppins bundle dans assets/fonts/ (plus de telechargement runtime).
    final textTheme = TextTheme(
      displayLarge: AppTypography.display,
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,
      titleLarge: AppTypography.h4,
      titleMedium: AppTypography.subtitle,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodySm,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      labelSmall: AppTypography.caption,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.n100,
      // Force Poppins partout : tout Text(...) sans style explicite herite
      // de fontFamily Poppins (sinon Flutter retombe sur Roboto/SF).
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle: AppTypography.pageTitle.copyWith(color: AppPalette.ink),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: AppPalette.n300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: AppPalette.n300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: AppPalette.teal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: AppPalette.danger, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppPalette.n500),
        labelStyle: TextStyle(color: AppPalette.n700),
      ),
    );
  }
}
