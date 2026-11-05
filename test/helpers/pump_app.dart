import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/i18n/translations.g.dart';

/// Pumps [child] inside the app shell: Riverpod overrides, v2 theme and the slang
/// translations in a fixed [locale] (French by default), so that any widget calling
/// `Translations.of(context)` works in a test.
Future<void> pumpAppWith(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
  AppLocale locale = AppLocale.fr,
}) async {
  LocaleSettings.setLocaleSync(locale);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: child,
        ),
      ),
    ),
  );
}
