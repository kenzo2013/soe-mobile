# SOE — Solution of Education

Application mobile Flutter (iOS + Android) de tutorat à domicile au Cameroun.

## Deux applications : « SOE » et « SOE Test »

Elles s'installent côte à côte sur un même téléphone.

| App | Identifiant (iOS et Android) | API | Doppler |
|---|---|---|---|
| **SOE** (production) | `cm.soe.mobile` | `https://api.solutionofeducation.com` | `soe-mobile` / `prd` |
| **SOE Test** (recette) | `cm.soe.mobile.test` | `https://api.jeteste.site` | `soe-mobile` / `stg` |

Les valeurs (`API_BASE_URL`, `GOOGLE_PLACES_API_KEY`, `ONESIGNAL_APP_ID`, `SENTRY_DSN`, clé de
signature Android) vivent dans le projet Doppler **`soe-mobile`**. Si Doppler ne trouve pas le
projet depuis ce dossier, il utilise un autre espace : `doppler setup -p soe-mobile -c prd`.

### Construire

```bash
./scripts/build.sh prod            # SOE, App Bundle Android (Play)
./scripts/build.sh test            # SOE Test, App Bundle Android
./scripts/build.sh test --apk      # SOE Test, APK à installer directement
./scripts/build.sh prod --ios      # SOE, IPA (App Store Connect)
```

Le script écrit l'identité de l'app (gitignorée) dans `android/env.properties` et
`ios/Flutter/Env.xcconfig`, restaure la clé d'envoi Play (`keys/upload-keystore.jks` et
`android/key.properties`) depuis Doppler si elle manque, puis lance `flutter clean` et
`flutter build` avec les `--dart-define`. Une valeur vide (OneSignal, Sentry) donne un
avertissement, pas une erreur. Version lue dans `pubspec.yaml` (ou `BUILD_NAME=… BUILD_NUMBER=…`).

Sans fichier d'identité (clone neuf, `flutter run` simple), Android et iOS construisent l'app
**SOE** de production (`ios/Flutter/AppIdentity.xcconfig`, `android/app/build.gradle.kts`).

### Lancer

```bash
./scripts/run.sh                   # dev : identité SOE Test, serveur Rails LOCAL via env/dev.env
./scripts/run.sh stg               # SOE Test sur la recette (vérifier une version, pas de données)
./scripts/run.sh prd               # SOE sur la production
```

En développement, l'app pointe sur le serveur **local** par un tunnel : copier
`env/example.env` en `env/dev.env` et y mettre l'adresse du tunnel (la config Doppler `dev`
reste vide). La commande directe marche toujours :
`flutter run --target=lib/main_dev.dart --dart-define-from-file=env/dev.env`.

### Icônes

`assets/icon/app_icon.png` (carré complet, iOS et stores) et `app_icon_foreground.png` (premier
plan adaptatif Android, fond `#01324A`). Après modification :

```bash
dart run flutter_launcher_icons && ./scripts/generate_test_icons.sh
```

Le second script dérive les icônes de SOE Test (bandeau « TEST ») : `ic_launcher_test` sur
Android, `AppIconTest` sur iOS.

## Tests

```bash
flutter test --coverage
```

Couverture cible : **≥ 80 %** sur `lib/features` et `lib/core` (gardé par CI).

## Lint & format

```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
```

## Architecture

Clean Architecture allégée — voir `REBUILD_SPEC.md`.

```
lib/
├── app/          — bootstrap, MaterialApp.router
├── core/         — env, network, error, storage, routing, theme, widgets, providers
└── features/<x>/
    ├── domain/        — entités pures, repositories abstract, usecases
    ├── data/          — DTOs, mappers, datasources, repository impl
    └── presentation/  — pages, widgets, viewmodels, routes, providers
```

**Règles dures :**

- Domain n'importe ni Flutter, ni Dio, ni Riverpod.
- Presentation ne dépend QUE de Domain.
- Tous les UseCases retournent `Future<Result<S, Failure>>`.
- Aucun `BuildContext` dans VM/UseCase/Repository/DataSource.

## Ajouter une feature

Voir les skills Claude Code dans `.claude/skills/` :

- `soe-feature-scaffold` — squelette complet
- `soe-usecase` — UseCase + test 100%
- `soe-viewmodel` — ViewModel + state freezed + tests des 4 états
- `soe-repository` — interface + impl + DTO + mapper + tests
- `soe-page` — Page MVVM
- `soe-route` — sous-route go_router
- `soe-checklist-done` — Definition of Done
- `soe-anti-patterns` — audit avant commit

Toute déviation à `REBUILD_SPEC.md` doit faire l'objet d'un ADR dans `docs/adr/`.

## CI

`.github/workflows/ci.yml` : format + analyze + test + coverage ≥ 80% à chaque PR.

`lefthook.yml` : pre-commit (format + analyze) + pre-push (test).

## Tests E2E

### ⚠️ Contrainte de chemin

**Le projet doit vivre sur un chemin sans espaces ni tirets** (caractères
non-identifier Dart). `_` est OK. Évite `Kevmax sarl/soe` ou `Kevmax-sarl/soe`,
préfère `~/code/soe` ou `~/Documents/Kevmax_sarl/soe`. Bug connu de
patrol_cli/Flutter dans la génération du `test_bundle.dart`.

### Mode courant — `flutter test integration_test`

```bash
# Lister les devices
flutter devices

# Sur simulateur iOS booté
open -a Simulator
flutter test integration_test/auth_smoke_test.dart -d <device-id>

# Sur émulateur Android
flutter test integration_test/auth_smoke_test.dart -d <android-id>
```

Scénarios actuels (`integration_test/`) :

- `auth_smoke_test.dart` — onboarding → role → 4 étapes signup ; login → forgot.

### Mode `patrol test` natif (à activer plus tard)

Patrol natif (interaction avec permissions OS, deep links système,
biométrie) demande une cible Xcode `RunnerUITests` non encore configurée.
À ajouter quand on aura besoin de tester la confirmation email via deep link
sur device réel :

1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. File → New → Target → UI Testing Bundle → `RunnerUITests`
3. Suivre <https://patrol.leancode.co/documentation/patrol-cli/setup-ios>
4. Workaround bug path : avant chaque run, `mkdir -p patrol_test && ln -snf /Users patrol_test/Users`
5. `patrol test --target integration_test/auth_smoke_test.dart -d <device>`

Setup CLI (déjà en place ici) :

```bash
dart pub global activate patrol_cli
export ANDROID_HOME="$HOME/Library/Android/sdk"
brew install ideviceinstaller    # uniquement pour device iOS réel
```

## MCP — pilotage du simulateur

`.mcp.json` configure le serveur **mobile-mcp** (`@mobilenext/mobile-mcp`)
qui permet à Claude de piloter directement l'iOS Simulator et l'émulateur
Android (boot, lancer l'app, taper, screenshot, accessibility tree). Utile
pour des smoke tests interactifs ; **complémentaire** à Patrol (qui reste
le standard CI).
