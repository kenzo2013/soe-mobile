import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Garde simple basée sur la présence d'un token et le rôle courant.
class AuthGuard {
  AuthGuard({required this.isAuthenticated, required this.currentRole});

  final bool Function() isAuthenticated;
  final String? Function() currentRole;

  static const Set<String> _publicRoutes = {
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.login,
    RouteNames.register,
    RouteNames.passwordForgot,
    RouteNames.emailConfirmation,
  };

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    final isPublic = _publicRoutes.any(loc.startsWith);

    if (!isAuthenticated()) {
      return isPublic ? null : RouteNames.login;
    }

    if (loc == RouteNames.login || loc == RouteNames.register) {
      return _homeForRole(currentRole());
    }

    if (loc.startsWith('/parent') && currentRole() != 'parent') {
      return _homeForRole(currentRole());
    }
    if (loc.startsWith('/tutor') && currentRole() != 'tutor') {
      return _homeForRole(currentRole());
    }

    return null;
  }

  String _homeForRole(String? role) => switch (role) {
        'tutor' => RouteNames.tutorDashboard,
        _ => RouteNames.parentDashboard,
      };
}
