import 'package:flutter/material.dart';

import 'app_palette.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.secondary,
      primary: AppPalette.primary,
      secondary: AppPalette.secondary,
      error: AppPalette.error,
      surface: AppPalette.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.background,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 26,
          color: AppPalette.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 21,
          color: AppPalette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: AppPalette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppPalette.textSecondary,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.textPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.textTertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.textTertiary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        hintStyle: const TextStyle(color: AppPalette.textTertiary),
      ),
    );
  }
}
