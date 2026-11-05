import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/core/storage/storage_keys.dart';
import 'package:soe/core/theme/app_theme.dart';
import 'package:soe/features/auth/domain/entities/auth_flow.dart';
import 'package:soe/features/auth/domain/entities/auth_session.dart';
import 'package:soe/features/auth/domain/entities/sign_up_answers.dart';
import 'package:soe/features/auth/domain/entities/user.dart';
import 'package:soe/features/auth/domain/repositories/auth_repository.dart';
import 'package:soe/features/auth/presentation/providers.dart';
import 'package:soe/features/auth/presentation/routes.dart';
import 'package:soe/features/parent_space/presentation/parent_space_routes.dart';
import 'package:soe/features/tutor_space/presentation/tutor_space_routes.dart';
import 'package:soe/i18n/translations.g.dart';

class _Storage extends Mock implements SecureStorage {}

/// A repository whose answers each test chooses.
class FakeAuthRepository implements AuthRepository {
  Result<SignInOutcome, Failure> signInResult =
      const Err(InvalidCredentialsFailure());
  Result<void, Failure> validateResult = const Ok(null);
  Result<PendingConfirmation, Failure>? signUpResult;
  final List<SignUpStep> validatedSteps = [];
  SignUpAnswers? createdWith;

  static const pending = PendingConfirmation(
      pendingToken: 'p', maskedEmail: 'a•••••@example.com', resendIn: 0);
  static AuthSession session([String role = 'parent']) => AuthSession(
        accessToken: 'jwt',
        user: User(
            id: '1',
            email: 'a@example.com',
            firstName: 'Awa',
            lastName: 'Ngono',
            role: UserRoleX.fromApi(role)),
      );

  /// The identifier of the last sign-in.
  String? lastLogin;

  @override
  Future<Result<SignInOutcome, Failure>> signIn(
      {required String login, required String password}) async {
    lastLogin = login;
    return signInResult;
  }

  @override
  Future<Result<void, Failure>> validateSignUpStep(
      {required SignUpStep step, required SignUpAnswers answers}) async {
    validatedSteps.add(step);
    return validateResult;
  }

  @override
  Future<Result<PendingConfirmation, Failure>> signUp(
      SignUpAnswers answers) async {
    createdWith = answers;
    return signUpResult ?? const Ok(pending);
  }

  @override
  Future<Result<AuthSession, Failure>> confirmEmail(
          {required String pendingToken, required String code}) async =>
      switch (code) {
        '123456' => Ok(session()),
        '999999' => const Err(LinkExpiredFailure()),
        _ => const Err(CodeFailure(CodeProblem.invalid)),
      };

  @override
  Future<Result<PendingConfirmation, Failure>> resendConfirmation(
          String pendingToken) async =>
      const Ok(pending);

  @override
  Future<Result<PasswordResetTicket, Failure>> requestPasswordReset(
          String login) async =>
      const Ok(PasswordResetTicket(resetToken: 'r', resendIn: 0));

  @override
  Future<Result<String, Failure>> verifyResetCode(
          {required String resetToken, required String code}) async =>
      const Ok('verified');

  @override
  Future<Result<PasswordResetTicket, Failure>> resendPasswordReset(
          String resetToken) async =>
      const Ok(PasswordResetTicket(resetToken: 'r', resendIn: 0));

  @override
  Future<Result<AuthSession, Failure>> resetPassword({
    required String verifiedToken,
    required String password,
    required String passwordConfirmation,
  }) async =>
      Ok(session('tutor'));

  @override
  Future<Result<void, Failure>> logout() async => const Ok(null);

  @override
  Future<Result<User, Failure>> fetchCurrentUser() async => Ok(session().user);
}

/// The auth routes of the app, the two homes as placeholders, in French on a phone.
Future<void> pumpAuthApp(WidgetTester tester, FakeAuthRepository repository,
    {required String start, List<Override> overrides = const []}) async {
  tester.view.physicalSize = const Size(390, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({StorageKeys.preferredLang: 'fr'});
  final prefs = PreferencesStorage(await SharedPreferences.getInstance());
  final storage = _Storage();
  when(() => storage.write(any(), any())).thenAnswer((_) async {});
  LocaleSettings.setLocaleSync(AppLocale.fr);
  final router = GoRouter(
    initialLocation: start,
    routes: [
      ...authRoutes(),
      GoRoute(
          path: RouteNames.parentHome,
          builder: (_, __) => const Text('parent-home')),
      GoRoute(
          path: RouteNames.tutorHome,
          builder: (_, __) => const Text('tutor-home')),
      GoRoute(
          path: ParentSpaceRoutes.newChild,
          builder: (_, __) => const Text('new-child')),
      GoRoute(
          path: TutorSpaceRoutes.file,
          builder: (_, __) => const Text('tutor-file')),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        preferencesStorageProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(storage),
        ...overrides,
      ],
      child: TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
          locale: AppLocale.fr.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
