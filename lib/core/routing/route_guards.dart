import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

/// Garde simple basée sur la présence d'un token et le rôle courant.
class AuthGuard {
  AuthGuard({
    required this.isAuthenticated,
    required this.currentRole,
    required this.onboardingDone,
  });

  final bool Function() isAuthenticated;
  final String? Function() currentRole;
  final bool Function() onboardingDone;

  /// Routes publiques (préfixe).
  static const Set<String> _publicPrefixes = {
    RouteNames.splash,
    RouteNames.onboarding,
    RouteNames.roleChoice,
    RouteNames.login,
    RouteNames.register,
    RouteNames.passwordForgot,
    RouteNames.passwordReset,
    RouteNames.emailSent,
    RouteNames.emailConfirmed,
    RouteNames.emailConfirmation,
  };

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;

    if (loc == RouteNames.splash) {
      if (!onboardingDone()) return RouteNames.onboarding;
      if (!isAuthenticated()) return RouteNames.login;
      return _homeForRole(currentRole());
    }

    final isPublic = _publicPrefixes.any(loc.startsWith);

    if (!isAuthenticated()) {
      return isPublic ? null : RouteNames.login;
    }

    if (loc == RouteNames.login || loc.startsWith(RouteNames.register)) {
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
