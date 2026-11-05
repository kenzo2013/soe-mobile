import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/core_providers.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/routes.dart';
import '../../features/common/presentation/routes.dart';
import '../../features/parent/presentation/routes.dart';
import '../../features/parent_space/presentation/parent_space_router.dart';
import '../../features/shell/presentation/routes.dart';
import '../../features/tutor/presentation/routes.dart';
import 'route_guards.dart';
import 'route_names.dart';

/// The app router, built once per guard: a language change must not rebuild it (that sent
/// the user back to the start, e.g. to the first welcome slide).
final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(guard: ref.watch(authGuardProvider));
  ref.onDispose(router.dispose);
  return router;
});

/// Router racine — n'agrège que les sous-routes des features.
///
/// **Interdit** d'ajouter une route métier ici. Voir le skill `soe-route`.
GoRouter buildRouter({required AuthGuard guard}) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: guard.redirect,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      ...authRoutes(),
      ...shellRoutes(),
      ...parentRoutes(),
      ...parentSpaceRoutes(),
      ...tutorRoutes(),
      ...commonRoutes(),
    ],
    errorBuilder: (context, state) => const SplashPage(),
  );
}
