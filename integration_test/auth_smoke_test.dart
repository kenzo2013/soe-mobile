import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:soe/app/app.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/storage/secure_storage.dart';

/// Smoke test E2E du flow d'authentification SOE.
///
/// **Mode** : `flutter test integration_test` standard (sans patrol natif).
/// Pour les permissions OS et deep links → bascule en `patrol test` quand
/// la cible Xcode `RunnerUITests` sera ajoutée (cf. README §Tests E2E).
///
/// Ne va PAS jusqu'à la confirmation email réelle (dépend du backend mail).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('auth flow: onboarding → role → signup steps', (tester) async {
    final prefs = await PreferencesStorage.create();
    final secure = SecureStorage();
    await prefs.remove('onboarding_done_flag');
    await secure.clear();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(secure),
        ],
        child: const SoeApp(),
      ),
    );
    await tester.pumpAndSettle();

    // ─── 1. Onboarding (3 slides) ──────────────────────────────────────
    expect(find.text('Trouvez le tuteur idéal'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Suivez chaque séance'), findsOneWidget);
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Payez en toute sécurité'), findsOneWidget);
    await tester.tap(find.text('Connectez-vous'));
    await tester.pumpAndSettle();

    // ─── 2. RoleChoice ─────────────────────────────────────────────────
    expect(find.text('Comment souhaitez-vous utiliser SOE ?'), findsOneWidget);
    await tester.tap(find.text('Je suis parent'));
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // ─── 3. Signup Step 1 ──────────────────────────────────────────────
    expect(find.text('Commençons par vous'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'Jean');
    await tester.enterText(find.byType(TextField).at(1), 'Dupont');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // ─── 4. Signup Step 2 ──────────────────────────────────────────────
    expect(find.text('Vos coordonnées'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'e2e@example.com');
    await tester.enterText(find.byType(TextField).at(1), '699000000');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // ─── 5. Signup Step 3 ──────────────────────────────────────────────
    expect(find.text('Sécurisez votre compte'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'SecureP@ss1');
    await tester.enterText(find.byType(TextField).at(1), 'SecureP@ss1');
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // ─── 6. Signup Step 4 ──────────────────────────────────────────────
    expect(find.text('Votre adresse'), findsOneWidget);
    // L'envoi réel POST /users/register dépend du backend — on s'arrête là.
  });

  testWidgets('login → forgot password', (tester) async {
    final prefs = await PreferencesStorage.create();
    final secure = SecureStorage();
    await prefs.writeBool('onboarding_done_flag', value: true);
    await secure.clear();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStorageProvider.overrideWithValue(prefs),
          secureStorageProvider.overrideWithValue(secure),
        ],
        child: const SoeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Connectez-vous'), findsOneWidget);
    await tester.tap(find.text('Mot de passe oublié ?'));
    await tester.pumpAndSettle();

    expect(find.text('Mot de passe oublié ?'), findsAtLeastNWidgets(1));
    await tester.enterText(find.byType(TextField), 'e2e@example.com');
    // L'envoi réel POST /users/password dépend du backend — on s'arrête là.
  });
}
