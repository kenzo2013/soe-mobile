import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/i18n/translations.g.dart';

/// Wrapper for golden_toolkit scenarios: v2 theme, translations in a fixed [locale],
/// Riverpod [overrides]. Usage: `tester.pumpDeviceBuilder(builder, wrapper: soeGoldenWrapper())`.
Widget Function(Widget) soeGoldenWrapper({
  AppLocale locale = AppLocale.fr,
  List<Override> overrides = const [],
}) {
  LocaleSettings.setLocaleSync(locale);
  return (child) => ProviderScope(
        overrides: overrides,
        child: TranslationProvider(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: locale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            home: Material(child: child),
          ),
        ),
      );
}
