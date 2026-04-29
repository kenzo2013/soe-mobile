import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import 'pages/email_confirmed_page.dart';
import 'pages/email_sent_page.dart';
import 'pages/forgot_password_page.dart';
import 'pages/forgot_password_sent_page.dart';
import 'pages/login_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/reset_password_page.dart';
import 'pages/role_choice_page.dart';
import 'pages/signup_step1_page.dart';
import 'pages/signup_step2_page.dart';
import 'pages/signup_step3_page.dart';
import 'pages/signup_step4_page.dart';

List<RouteBase> authRoutes() => [
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.roleChoice,
        builder: (context, state) => const RoleChoicePage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.registerStep1,
        builder: (context, state) => const SignupStep1Page(),
      ),
      GoRoute(
        path: RouteNames.registerStep2,
        builder: (context, state) => const SignupStep2Page(),
      ),
      GoRoute(
        path: RouteNames.registerStep3,
        builder: (context, state) => const SignupStep3Page(),
      ),
      GoRoute(
        path: RouteNames.registerStep4,
        builder: (context, state) => const SignupStep4Page(),
      ),
      GoRoute(
        path: RouteNames.emailSent,
        builder: (context, state) => const EmailSentPage(),
      ),
      GoRoute(
        path: RouteNames.emailConfirmed,
        builder: (context, state) {
          final ok = state.uri.queryParameters['confirmed'] != 'false';
          return EmailConfirmedPage(success: ok);
        },
      ),
      GoRoute(
        path: RouteNames.passwordForgot,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: RouteNames.passwordForgotSent,
        builder: (context, state) => ForgotPasswordSentPage(
          email: state.uri.queryParameters['email'],
        ),
      ),
      GoRoute(
        path: RouteNames.passwordReset,
        builder: (context, state) {
          final token = state.uri.queryParameters['reset_password_token'] ??
              state.uri.queryParameters['token'] ??
              '';
          return ResetPasswordPage(token: token);
        },
      ),
    ];
