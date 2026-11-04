import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/routes.dart';
import '../../features/common/presentation/routes.dart';
import '../../features/parent/presentation/routes.dart';
import '../../features/tutor/presentation/routes.dart';
import 'route_guards.dart';
import 'route_names.dart';

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
      ...parentRoutes(),
      ...tutorRoutes(),
      ...commonRoutes(),
    ],
    errorBuilder: (context, state) => const SplashPage(),
  );
}
