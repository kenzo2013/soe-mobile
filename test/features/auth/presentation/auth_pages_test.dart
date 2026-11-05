import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/routing/route_names.dart';
import 'package:soe/features/auth/presentation/providers.dart';
import 'package:soe/core/widgets/soe_button.dart';
import 'package:soe/features/auth/domain/entities/auth_flow.dart';
import 'package:soe/features/auth/domain/entities/sign_up_answers.dart';
import 'package:soe/features/auth/presentation/controllers/auth_controllers.dart';

import 'auth_test_app.dart';

/// The field whose label (a Text above it, in the same column) is [label].
Future<void> _enter(WidgetTester tester, String label, String text) async {
  final column =
      find.ancestor(of: find.text(label), matching: find.byType(Column)).first;
  await tester.enterText(
      find.descendant(of: column, matching: find.byType(TextFormField)), text);
  await tester.pump();
}

Finder _button(String label) => find.widgetWithText(SoeButton, label);

bool _enabled(WidgetTester tester, String label) =>
    tester.widget<SoeButton>(_button(label)).onPressed != null;

void main() {
  group('AUT-09 sign-in', () {
    testWidgets(
        'the button waits for both fields, then opens the space of the role',
        (tester) async {
      final repository = FakeAuthRepository()
        ..signInResult = Ok(SignedIn(FakeAuthRepository.session()));
      await pumpAuthApp(tester, repository, start: RouteNames.login);

      expect(_enabled(tester, 'Se connecter'), isFalse);
      expect(find.text('Saisissez votre identifiant et votre mot de passe.'),
          findsOneWidget);
      await _enter(tester, 'E-mail ou téléphone', '6 99 00 01 11');
      await _enter(tester, 'Mot de passe', 'secret');
      await tester.tap(_button('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('parent-home'), findsOneWidget);
    });

    testWidgets('an unverified account goes to the code screen',
        (tester) async {
      final repository = FakeAuthRepository()
        ..signInResult =
            const Ok(ConfirmationRequired(FakeAuthRepository.pending));
      await pumpAuthApp(tester, repository, start: RouteNames.login);

      await _enter(tester, 'E-mail ou téléphone', 'a@example.com');
      await _enter(tester, 'Mot de passe', 'secret');
      await tester.tap(_button('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Vérifiez votre adresse e-mail'), findsOneWidget);
      expect(find.textContaining('a•••••@example.com'), findsOneWidget);
    });

    testWidgets('wrong credentials show the neutral message', (tester) async {
      final repository = FakeAuthRepository()
        ..signInResult = const Err(InvalidCredentialsFailure());
      await pumpAuthApp(tester, repository, start: RouteNames.login);

      await _enter(tester, 'E-mail ou téléphone', 'a@example.com');
      await _enter(tester, 'Mot de passe', 'wrong');
      await tester.tap(_button('Se connecter'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  testWidgets(
      'AUT-02 to AUT-08: a parent signs up, checks the code and lands on the welcome',
      (tester) async {
    final repository = FakeAuthRepository();
    await pumpAuthApp(tester, repository, start: RouteNames.roleChoice);

    expect(find.text('Choisissez un profil pour continuer.'), findsOneWidget);
    await tester.tap(find.text('Je cherche un répétiteur pour mon enfant'));
    await tester.pump();
    await tester.tap(_button('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Qui êtes-vous ?'), findsOneWidget);
    expect(find.textContaining('Il manque : civilité, prénom, nom'),
        findsOneWidget);
    await tester.tap(find.text('Mme'));
    await _enter(tester, 'Prénom', 'Awa');
    await _enter(tester, 'Nom', 'Ngono');
    await tester.tap(find.text('Mère'));
    await tester.pump();
    await tester.tap(_button('Continuer'));
    await tester.pumpAndSettle();

    await _enter(tester, 'Téléphone (+237)', '699000333');
    await _enter(tester, 'E-mail', 'awa@example.com');
    await tester.tap(_button('Continuer'));
    await tester.pumpAndSettle();

    await _enter(tester, 'Mot de passe', 'Bonjour-2026');
    await _enter(tester, 'Confirmer le mot de passe', 'Bonjour-2026');
    await tester.tap(_button('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Où habitez-vous ?'), findsOneWidget);
    await _enter(tester, 'Quartier', 'Makepe');
    await tester.tap(find.text('Douala'));
    for (final consent in [
      'J’accepte les conditions générales d’utilisation',
      'J’accepte les conditions générales de vente',
      'J’accepte le traitement de mes données selon la politique de confidentialité',
    ]) {
      await tester.tap(find.text(consent));
    }
    await tester.pump();
    await tester.tap(_button('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(repository.validatedSteps, [
      SignUpStep.profile,
      SignUpStep.identity,
      SignUpStep.contact,
      SignUpStep.password
    ]);
    expect(repository.createdWith?.city, 'Douala');
    expect(find.text('Vérifiez votre adresse e-mail'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();

    expect(find.text('Votre compte est activé'), findsOneWidget);
    await tester.tap(_button('Ajouter mon premier enfant'));
    await tester.pumpAndSettle();
    expect(find.text('new-child'), findsOneWidget);

    // The form opens over the parent home: back leads there.
    GoRouter.of(tester.element(find.text('new-child'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('parent-home'), findsOneWidget);
  });

  testWidgets(
      'AUT-08: a new tutor lands on the recruitment file, over the home',
      (tester) async {
    await pumpAuthApp(tester, FakeAuthRepository(),
        start: RouteNames.emailConfirmed);
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
        .read(currentRoleProvider.notifier)
        .state = 'tutor';
    await tester.pumpAndSettle();

    await tester.tap(_button('Compléter mon dossier'));
    await tester.pumpAndSettle();
    expect(find.text('tutor-file'), findsOneWidget);

    GoRouter.of(tester.element(find.text('tutor-file'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('tutor-home'), findsOneWidget);
  });

  testWidgets(
      'AUT-10: identifier, code, new password, then the space of the role',
      (tester) async {
    await pumpAuthApp(tester, FakeAuthRepository(),
        start: RouteNames.passwordForgot);

    await _enter(tester, 'E-mail ou téléphone', 'a@example.com');
    await tester.tap(_button('Recevoir un code'));
    await tester.pumpAndSettle();

    expect(find.text('Saisissez le code'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '424242');
    await tester.pumpAndSettle();

    expect(find.text('Nouveau mot de passe'), findsWidgets);
    await _enter(tester, 'Mot de passe', 'Nouveau-2026!');
    await _enter(tester, 'Confirmer le mot de passe', 'Nouveau-2026!');
    await tester.tap(_button('Enregistrer et me connecter'));
    await tester.pumpAndSettle();

    expect(find.text('tutor-home'), findsOneWidget);
  });

  testWidgets('an expired code offers to start again', (tester) async {
    final repository = FakeAuthRepository()
      ..signInResult =
          const Ok(ConfirmationRequired(FakeAuthRepository.pending));
    await pumpAuthApp(tester, repository, start: RouteNames.login);
    await _enter(tester, 'E-mail ou téléphone', 'a@example.com');
    await _enter(tester, 'Mot de passe', 'secret');
    await tester.tap(_button('Se connecter'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '999999');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recommencer'));
    await tester.pumpAndSettle();

    expect(find.text('Bon retour parmi nous'), findsOneWidget);
  });

  testWidgets('step 4 shows a refusal about a field of an earlier step',
      (tester) async {
    final repository = FakeAuthRepository()
      ..signUpResult = const Err(ValidationFailure({
        'email': ['Cet e-mail est déjà utilisé.'],
      }));
    await pumpAuthApp(tester, repository, start: RouteNames.registerStep4);
    final container =
        ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    container.read(signUpControllerProvider.notifier).update((a) => a.copyWith(
          role: 'parent',
          city: 'Douala',
          neighborhood: 'Makepe',
          acceptTermsOfUse: true,
          acceptTermsOfSale: true,
          acceptPrivacy: true,
        ));
    await tester.pumpAndSettle();
    await tester.tap(_button('Créer mon compte'));
    await tester.pumpAndSettle();

    expect(find.text('Cet e-mail est déjà utilisé.'), findsOneWidget);
  });

  test('the answers (password included) are forgotten once the account exists',
      () async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
    ]);
    addTearDown(container.dispose);
    final controller = container.read(signUpControllerProvider.notifier);
    controller.update(
        (a) => a.copyWith(password: 'Bonjour-2026', email: 'a@example.com'));

    await controller.create();

    expect(container.read(signUpControllerProvider).answers.password, isEmpty);
    expect(container.read(confirmationControllerProvider).pending, isNotNull);
  });

  test('the answers are forgotten when someone signs in or out', () async {
    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
    ]);
    addTearDown(container.dispose);
    container
        .read(signUpControllerProvider.notifier)
        .update((a) => a.copyWith(password: 'x'));

    container.read(authTokenProvider.notifier).state = 'jwt';

    expect(container.read(signUpControllerProvider).answers.password, isEmpty);
  });
}
