import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/forgot_password_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

List<RouteBase> authRoutes() => [
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: RouteNames.passwordForgot,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
    ];
