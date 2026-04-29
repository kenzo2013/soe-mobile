import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/providers/core_providers.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';

class SoeApp extends ConsumerWidget {
  const SoeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guard = ref.watch(authGuardProvider);
    final router = buildRouter(guard: guard);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      child: MaterialApp.router(
        title: 'SOE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr'), Locale('en')],
      ),
    );
  }
}
