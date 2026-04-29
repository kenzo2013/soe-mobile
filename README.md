# SOE — Solution of Education

Application mobile Flutter (iOS + Android) de tutorat à domicile au Cameroun.

Bundle ID : `cm.soe.mobile`.

## Démarrage rapide

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Lancer en dev / staging / prod

```bash
flutter run --target=lib/main_dev.dart       --dart-define-from-file=env/dev.env
flutter run --target=lib/main_staging.dart   --dart-define-from-file=env/staging.env
flutter run --target=lib/main_prod.dart      --dart-define-from-file=env/prod.env
```

Les fichiers `env/*.env` sont gitignorés. Voir `env/example.env` pour la liste des variables.

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
