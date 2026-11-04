import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Material theme built from the v2 tokens. Screens still use the `Soe*` widgets; this theme
/// only makes the defaults (plain `Text`, system dialogs, v1 inputs) match the Studio.
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.teal500,
      primary: AppPalette.teal500,
      secondary: AppPalette.gold400,
      error: AppPalette.dangerText,
      surface: AppPalette.white,
    );

    final textTheme = TextTheme(
      displayLarge: AppTypography.display,
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,
      titleLarge: AppTypography.title,
      titleMedium: AppTypography.subtitle,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.bodySm,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.label,
      labelSmall: AppTypography.caption,
    );

    // Studio fields: label above, soft fill, no border at rest, 2 px ring on focus / error.
    const fieldRadius = AppRadius.rMd;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.surfacePage,
      // Every Text without an explicit style inherits Figtree (otherwise Roboto / SF).
      fontFamily: AppTypography.uiFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        // Titles aligned left everywhere (iOS default = centred).
        centerTitle: false,
        backgroundColor: AppPalette.surfacePage,
        titleTextStyle: AppTypography.title.copyWith(color: AppPalette.teal800),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surfaceSoft,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: fieldRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: fieldRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: AppPalette.teal500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: AppPalette.dangerText, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: AppPalette.dangerText, width: 2),
        ),
        hintStyle: TextStyle(color: AppPalette.ink600),
        labelStyle: TextStyle(color: AppPalette.text),
        errorStyle: TextStyle(color: AppPalette.dangerText),
      ),
    );
  }
}
