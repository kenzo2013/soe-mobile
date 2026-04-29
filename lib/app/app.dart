import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/providers/core_providers.dart';
import '../core/providers/locale_provider.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../i18n/translations.g.dart';

class SoeApp extends ConsumerWidget {
  const SoeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guard = ref.watch(authGuardProvider);
    final locale = ref.watch(localeProvider);
    final router = buildRouter(guard: guard);

    return TranslationProvider(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        child: MaterialApp.router(
          title: 'SOE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: router,
          locale: locale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
