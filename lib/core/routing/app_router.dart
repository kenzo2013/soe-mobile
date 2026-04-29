import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/routes.dart';
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
        builder: (context, state) => const _SplashPlaceholder(),
      ),
      ...authRoutes(),
      // ...parentRoutes(),
      // ...tutorRoutes(),
      // ...commonRoutes(),
    ],
  );
}

class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
