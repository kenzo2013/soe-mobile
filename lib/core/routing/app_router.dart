import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/routes.dart';
import '../../features/common/presentation/routes.dart';
import '../../features/parent_space/presentation/parent_space_router.dart';
import '../../features/shell/presentation/routes.dart';
import '../../features/tutor_space/presentation/tutor_space_router.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// The app router, built once per guard: a language change must not rebuild it (that sent
/// the user back to the start, e.g. to the first welcome slide).
/// When the session ends (expired, revoked, signed out), the guard runs again at once: the
/// screens of a space never stay on an error without a session.
final routerProvider = Provider<GoRouter>((ref) {
  final sessionEnded = ValueNotifier<int>(0);
  ref.listen(authTokenProvider, (previous, next) {
    if (previous != null && next == null) sessionEnded.value++;
  });
  final router = buildRouter(
      guard: ref.watch(authGuardProvider), refreshListenable: sessionEnded);
  ref.onDispose(() {
    router.dispose();
    sessionEnded.dispose();
  });
  return router;
});

/// Router racine — n'agrège que les sous-routes des features.
///
/// **Interdit** d'ajouter une route métier ici. Voir le skill `soe-route`.
GoRouter buildRouter(
    {required AuthGuard guard, Listenable? refreshListenable}) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: guard.redirect,
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      ...authRoutes(),
      ...shellRoutes(),
      ...parentSpaceRoutes(),
      ...tutorSpaceRoutes(),
      ...commonRoutes(),
    ],
    errorBuilder: (context, state) => const SplashPage(),
  );
}
