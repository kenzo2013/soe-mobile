# SOE — Store of Excellence

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

## Tests E2E (Patrol)

Patrol pilote l'app sur un simulateur réel et peut interagir avec l'OS
(permissions natives, deep links, notifications).

### Setup initial (une fois par machine)
```bash
dart pub global activate patrol_cli   # >= 4.x — `bootstrap` n'existe plus,
                                       # les harness natifs sont générés au
                                       # premier `patrol test`/`develop`.
brew install ideviceinstaller          # uniquement si tu testes sur device iOS réel
export ANDROID_HOME="$HOME/Library/Android/sdk"   # à mettre dans ~/.zshrc
```

### Lancer les tests
```bash
# Lister les devices disponibles
patrol devices

# Sur simulateur iOS booté
open -a Simulator
patrol test --target integration_test/auth_smoke_test.dart

# Sur émulateur Android
patrol test --target integration_test/auth_smoke_test.dart -d <device-id>

# Mode dev (hot restart, pratique pour itérer sur un test)
patrol develop --target integration_test/auth_smoke_test.dart
```

Scénarios actuels (`integration_test/`) :
- `auth_smoke_test.dart` — onboarding → role → 4 étapes signup ; login → forgot.

## MCP — pilotage du simulateur

`.mcp.json` configure le serveur **mobile-mcp** (`@mobilenext/mobile-mcp`)
qui permet à Claude de piloter directement l'iOS Simulator et l'émulateur
Android (boot, lancer l'app, taper, screenshot, accessibility tree). Utile
pour des smoke tests interactifs ; **complémentaire** à Patrol (qui reste
le standard CI).
