import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:soe/app/app.dart';
import 'package:soe/core/storage/preferences_storage.dart';
import 'package:soe/core/storage/secure_storage.dart';
import 'package:soe/core/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smoke test E2E du flow d'authentification SOE.
///
/// **Note** : ce test ne va PAS jusqu'à la confirmation email réelle (qui
/// dépend du backend mail). Il valide :
///   1. Onboarding (3 slides)
///   2. RoleChoice → parent
///   3. Signup step 1 → step 2 → step 3 → step 4
///
/// Pour la confirmation email + reset password, utiliser le serveur de
/// test (mailinator ou stub) — non couvert ici.
void main() {
  patrolTest(
    'auth flow: onboarding → role → signup steps',
    ($) async {
      final prefs = await PreferencesStorage.create();
      final secure = SecureStorage();
      // Reset onboarding flag so the test starts from the very beginning.
      await prefs.remove('onboarding_done_flag');
      await secure.clear();

      await $.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStorageProvider.overrideWithValue(prefs),
            secureStorageProvider.overrideWithValue(secure),
          ],
          child: const SoeApp(),
        ),
      );
      await $.pumpAndSettle();

      // ─── 1. Onboarding (3 slides) ──────────────────────────────────────
      expect($('Trouvez le tuteur idéal'), findsOneWidget);
      await $('Suivant').tap();
      await $.pumpAndSettle();
      expect($('Suivez chaque séance'), findsOneWidget);
      await $('Suivant').tap();
      await $.pumpAndSettle();
      expect($('Payez en toute sécurité'), findsOneWidget);
      await $('Connectez-vous').tap();
      await $.pumpAndSettle();

      // ─── 2. RoleChoice ─────────────────────────────────────────────────
      expect($('Comment souhaitez-vous utiliser SOE ?'), findsOneWidget);
      await $('Je suis parent').tap();
      await $('Continuer').tap();
      await $.pumpAndSettle();

      // ─── 3. Signup Step 1 ──────────────────────────────────────────────
      expect($('Commençons par vous'), findsOneWidget);
      await $(TextField).at(0).enterText('Jean');
      await $(TextField).at(1).enterText('Dupont');
      await $('Continuer').tap();
      await $.pumpAndSettle();

      // ─── 4. Signup Step 2 ──────────────────────────────────────────────
      expect($('Vos coordonnées'), findsOneWidget);
      await $(TextField).at(0).enterText('e2e@example.com');
      await $(TextField).at(1).enterText('699000000');
      await $('Continuer').tap();
      await $.pumpAndSettle();

      // ─── 5. Signup Step 3 ──────────────────────────────────────────────
      expect($('Sécurisez votre compte'), findsOneWidget);
      await $(TextField).at(0).enterText('SecureP@ss1');
      await $(TextField).at(1).enterText('SecureP@ss1');
      await $('Continuer').tap();
      await $.pumpAndSettle();

      // ─── 6. Signup Step 4 ──────────────────────────────────────────────
      expect($('Votre adresse'), findsOneWidget);
      // L'envoi réel POST /users/register dépend du backend — on s'arrête là.
    },
  );

  patrolTest(
    'login → forgot password',
    ($) async {
      final prefs = await PreferencesStorage.create();
      final secure = SecureStorage();
      // Marque l'onboarding comme déjà vu pour atterrir directement sur login.
      await prefs.writeBool('onboarding_done_flag', value: true);
      await secure.clear();

      await $.pumpWidget(
        ProviderScope(
          overrides: [
            preferencesStorageProvider.overrideWithValue(prefs),
            secureStorageProvider.overrideWithValue(secure),
          ],
          child: const SoeApp(),
        ),
      );
      await $.pumpAndSettle();

      expect($('Connectez-vous'), findsOneWidget);
      await $('Mot de passe oublié ?').tap();
      await $.pumpAndSettle();

      expect($('Mot de passe oublié ?'), findsAtLeastNWidgets(1));
      await $(TextField).enterText('e2e@example.com');
      // L'envoi réel POST /users/password dépend du backend — on s'arrête là.
    },
  );
}
