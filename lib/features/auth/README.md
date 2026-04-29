# Feature `auth`

Authentification SOE — onboarding, choix du rôle, login, inscription multi-étapes,
confirmation email (deep link), mot de passe oublié + reset (deep link).

## Endpoints API consommés
| Méthode | Endpoint | Description |
|---|---|---|
| POST | `/users/login` | Connexion (retourne `accessToken` JWT 30 jours) |
| POST | `/users/register` | Inscription parent ou tuteur — **pas de token** retourné |
| POST | `/users/password` | Demande de réinitialisation (envoie un email) |
| PATCH | `/users/password` | Réinitialise via `reset_password_token` |
| DELETE | `/users/logout` | Déconnexion |

## Formats de réponse réels (testés avec curl sur api.jeteste.site)

- **Login** :
  - 200 → `{"data": {"id":"31","type":"user","attributes":{...}}, "accessToken":"..."}`
  - 401 (mauvais identifiants) → `{"error":"Invalid E-mail or password."}`
  - 401 (email pas confirmé) → `{"error":"You have to confirm your email address before continuing."}`

- **Register** :
  - 201 → `{"status":{"code":200,"message":"Signed up successfully."}, "data":{...user...}}`
  - 422 → `{"status":{"code":422,"message":"<msg concaténé>"}}`

- **Password** :
  - 200 → `{"status":{"code":200,"message":"Email envoyé."}}`
  - 422 → `{"status":{"code":422,"message":"E-mail not found"}}`

`ExceptionMapper` détecte les deux formats `{"error":...}` et `{"status":{...}}`.

## Flow

```
Splash
  ├─ onboarding non vu → Onboarding (3 slides) → RoleChoice
  ├─ pas de token → Login
  └─ token + role → Dashboard
RoleChoice → Signup Step1 → Step2 → Step3 → Step4 → POST /register → EmailSent
EmailSent (attente confirmation par lien email)
   └─ Deep link soe://app/auth/email-confirmed?confirmed=true → EmailConfirmed → Login

Login
  └─ "Mot de passe oublié" → ForgotPassword → POST /password → ForgotPasswordSent
                                                              └─ Deep link soe://app/password/reset?reset_password_token=XXX → ResetPassword → PATCH /password → Authenticated
```

## Deep links

### Schéma
`soe://app/<path>` où `<path>` est une route go_router de l'app.

### Routes attendues
| Lien email envoyé par le serveur | Path go_router |
|---|---|
| `soe://app/auth/email-confirmed?confirmed=true` | `/auth/email-confirmed` |
| `soe://app/password/reset?reset_password_token=XXX` | `/password/reset` |

### Configuration native
- **iOS** : `Info.plist` contient `CFBundleURLSchemes=[soe]` et `FlutterDeepLinkingEnabled=true`.
- **Android** : `AndroidManifest.xml` contient un `<intent-filter>` avec `<data android:scheme="soe" android:host="app"/>` et `flutter_deeplinking_enabled=true`.

### Côté backend
Le serveur doit générer ses URLs avec `soe://app` au lieu de `https://app.jeteste.site` (ou maintenir une page web qui détecte mobile et redirige).

## UseCases

| UseCase | Méthode | Notes |
|---|---|---|
| `Login` | `call({email, password})` | Validation locale email + non-vide |
| `Register` | `call({params})` | Valide CGU, password ≥ 6, confirmation. **Retourne `User` (pas de session)** — login bloqué tant que email pas confirmé. |
| `RequestPasswordReset` | `call({email})` | Validation email locale |
| `ResetPassword` | `call({token, password, passwordConfirmation})` | Reconnecte automatiquement (PATCH retourne accessToken) |
| `Logout` | `call()` | Efface tokens locaux même si serveur échoue |

## i18n
Strings dans `lib/i18n/fr.i18n.json` + `en.i18n.json` (slang). Toggle pill langue via `LangPill` (présente sur Onboarding, RoleChoice, Login).

## Sécurité
- Tokens uniquement dans `flutter_secure_storage`.
- Mot de passe jamais loggé (pas même en debug).
- `AuthInterceptor` purge le token sur 401.
