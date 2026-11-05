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

  /// Public routes, by prefix. The splash (`/`) is matched exactly: as a prefix it would make
  /// every screen public, and a session refused by the API would stay inside the tabs.
  static const Set<String> _publicPrefixes = {
    RouteNames.onboarding,
    RouteNames.roleChoice,
    RouteNames.login,
    RouteNames.register,
    RouteNames.passwordForgot,
    RouteNames.passwordForgotSent,
    RouteNames.passwordReset,
    RouteNames.emailSent,
    RouteNames.emailConfirmed,
  };

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;

    if (loc == RouteNames.splash) {
      if (!onboardingDone()) return RouteNames.onboarding;
      if (!isAuthenticated()) return RouteNames.login;
      return _homeForRole(currentRole());
    }

    final isPublic =
        loc == RouteNames.splash || _publicPrefixes.any(loc.startsWith);

    if (!isAuthenticated()) {
      return isPublic ? null : RouteNames.login;
    }

    // Signed in: the sign-in and sign-up screens send home, except AUT-08 (account activated),
    // which follows the e-mail code.
    if (loc == RouteNames.login ||
        (loc.startsWith(RouteNames.register) &&
            loc != RouteNames.emailConfirmed)) {
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
        'tutor' => RouteNames.tutorHome,
        _ => RouteNames.parentHome,
      };
}
