# Feature `auth`

Authentification SOE sur l'**API v2** (`/api/v2`, enveloppe `{ data, meta, errors }`) :
accueil, choix parent ou répétiteur, inscription en quatre étapes, code à 6 chiffres reçu par
e-mail, connexion par e-mail ou téléphone, mot de passe oublié par code, session expirée.

Contrat de référence : `soe/docs/api/v2/openapi.yml`. Chemins : `lib/core/network/api_endpoints_v2.dart`.

## Écrans (Studio AUT-00 à AUT-12)

| Écran | Page | Route |
|---|---|---|
| AUT-00 lancement | `SplashPage` | `/` |
| AUT-01 accueil (4 diapositives) | `OnboardingPage` | `/onboarding` |
| AUT-02 parent ou répétiteur | `RoleChoicePage` | `/role` |
| AUT-03 identité | `SignupStep1Page` | `/register/identity` |
| AUT-04 contact (+237, e-mail) | `SignupStep2Page` | `/register/contact` |
| AUT-05 mot de passe (4 règles) | `SignupStep3Page` | `/register/password` |
| AUT-06 adresse et consentements | `SignupStep4Page` | `/register/address` |
| AUT-07 code de vérification | `EmailSentPage` | `/register/email-sent` |
| AUT-08 compte activé | `EmailConfirmedPage` | `/register/email-confirmed` |
| AUT-09 connexion | `LoginPage` | `/login` |
| AUT-10 mot de passe oublié (identifiant, code, nouveau mot de passe) | `ForgotPasswordPage`, `ForgotPasswordSentPage`, `ResetPasswordPage` | `/password/forgot`, `/password/forgot-sent`, `/password/reset` |
| AUT-11 session expirée | `LoginPage` (variante) | `/login` |

Le bouton principal de chaque écran est or (`SoeButtonVariant.primary`), comme le web ;
seul « Suivant » de l'accueil reste teal.

## Endpoints API v2 consommés

| Méthode | Endpoint | Usage |
|---|---|---|
| POST | `/auth/session` | Connexion `{login, password}` : 200 → `{token, token_expires_at, user}` ; 202 → compte non vérifié, `{pending_token, …}` (AUT-07) |
| DELETE | `/auth/session` | Déconnexion (révoque le jeton) |
| POST | `/auth/registrations/validate` | Valide une étape `{step, sign_up}` avant la suivante |
| POST | `/auth/registrations` | Crée le compte `{sign_up}` → `{pending_token, …}` ; aucun jeton tant que le code n'est pas saisi |
| POST | `/auth/confirmations` | Code reçu `{pending_token, code}` → session |
| POST | `/auth/confirmations/resend` | Renvoie le code |
| POST | `/auth/password_resets` | Mot de passe oublié `{login}` → `{reset_token, …}` (même réponse que le compte existe ou non) |
| POST | `/auth/password_resets/verify` | Code `{reset_token, code}` → `{verified_token}` |
| POST | `/auth/password_resets/resend` | Renvoie le code |
| PUT | `/auth/password_resets` | Nouveau mot de passe `{verified_token, password, password_confirmation}` → session |
| GET | `/me` | Compte connecté : identité, langue, rôles, rôle actif |

Les erreurs arrivent dans `errors[]` avec un `code` que `ExceptionMapper` traduit :
`invalid_credentials`, `unconfirmed`, `unauthenticated`, `rate_limited`, `code_invalid`,
`code_expired`, `code_locked`, `link_expired`, et `ValidationFailure` pour les champs.

## Parcours

```
Lancement
  ├─ accueil jamais vu → Accueil (4 diapositives) → Parent ou répétiteur
  ├─ pas de session    → Connexion
  └─ session + rôle    → espace parent (/parent) ou répétiteur (/tutor)

Parent ou répétiteur → Identité → Contact → Mot de passe → Adresse
  → POST /auth/registrations → Code (AUT-07) → POST /auth/confirmations → Compte activé (AUT-08)

Connexion → POST /auth/session
  ├─ 200 → espace du rôle
  └─ 202 → Code (AUT-07), puis espace du rôle

Mot de passe oublié → identifiant → code → nouveau mot de passe → espace du rôle
```

## Session expirée (AUT-11)

Un 401 reçu alors qu'une session est enregistrée (jeton expiré ou révoqué, par exemple après
un changement de mot de passe sur un autre appareil) :

1. `AuthInterceptor` appelle `onUnauthorized` (`core_providers.dart`) : le jeton est effacé,
   `sessionExpiredProvider` passe à `true`, `authTokenProvider` à `null`.
2. Le routeur (`routerProvider`) écoute la fin de session et relance sa garde : tout écran
   d'un espace renvoie aussitôt à `/login`, au lieu d'afficher « Réessayer » dans les onglets.
3. `LoginPage` affiche « Votre session a expiré » avec le compte gardé (nom, e-mail masqué) :
   seul le mot de passe est demandé ; « Changer de compte » oublie ce compte et revient à la
   connexion ordinaire. Une connexion réussie remet `sessionExpiredProvider` à `false`.

Un 401 sans session enregistrée (mauvais mot de passe) ne déclenche rien de tout cela.

## Sécurité

- Jeton et compte uniquement dans `flutter_secure_storage` (`StorageKeys.authToken`,
  `StorageKeys.currentUser`).
- Les réponses de l'inscription (mot de passe compris) sont oubliées dès que le compte existe
  et à chaque connexion ou déconnexion.
- Mot de passe jamais journalisé.
- La déconnexion efface la session locale même si le serveur ne répond pas.

## Textes

`lib/i18n/fr.i18n.json` et `en.i18n.json` (slang), clés `auth.*`. En français, on dit
toujours « répétiteur ».
