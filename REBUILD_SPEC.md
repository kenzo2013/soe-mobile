# Go4School Mobile — Spécification de refonte

> Document de cadrage destiné au développeur senior en charge de la reconstruction de la base de code.
> Objectif : repartir d'une fondation propre, testée, sécurisée et maintenable, en conservant le périmètre fonctionnel actuel.

---

## 1. Contexte & objectifs

### 1.1 Contexte
Go4School est une application Flutter mobile (iOS / Android) destinée à trois personae : **élèves**, **parents**, **enseignants/staff**. Elle couvre 27 features métier (cours, évaluations, bulletins, paiements, communication, présences, stories, etc.).

La base actuelle a été construite itérativement par plusieurs intervenants. Elle fonctionne en production mais a accumulé une dette technique qui ralentit chaque nouvelle livraison et fragilise la qualité.

### 1.2 Objectifs de la refonte
| # | Objectif | KPI cible |
|---|----------|-----------|
| 1 | Réduire le coût d'ajout d'une feature | ≤ 3 jours pour une feature CRUD standard |
| 2 | Garantir la non-régression | Couverture de tests ≥ **80 %** sur `lib/features` et `lib/core` |
| 3 | Sécuriser l'app | 0 secret en clair, SSL strict, secure storage généralisé |
| 4 | Stabiliser les livraisons | Pipeline CI vert obligatoire avant merge, build APK/IPA automatisé |
| 5 | Onboarder un nouveau dev | Productif en ≤ 2 jours grâce à la doc + conventions |

### 1.3 Hors-périmètre
- Refonte du backend (l'API REST reste identique).
- Changement du design UI (la charte graphique actuelle est conservée).
- Migration vers une autre techno (on reste sur Flutter).

---

## 2. Audit de l'existant

### 2.1 Points forts à conserver
- **Architecture feature-first MVVM** avec Riverpod : la séparation `data / viewmodels / presentation` est saine et doit être prolongée.
- **Code generation** déjà en place (`freezed`, `json_serializable`, `riverpod_generator`).
- **Localisation typée** via `slang` (FR base, EN secondaire).
- **APIService centralisé** avec `dio` + `pretty_dio_logger`.
- **Tests présents** (≈ 362 fichiers, 28 ViewModels couverts) : la culture du test existe, il faut la systématiser.

### 2.2 Faiblesses identifiées

#### Sécurité (CRITIQUE — à traiter en priorité)
- `MyHttpOverrides.badCertificateCallback` retourne **toujours `true`** (`lib/main.dart`) → l'app accepte n'importe quel certificat SSL, y compris des MITM. **Doit être supprimé.**
- Clés API en dur dans `lib/core/variables/base__url.dart` (`GOOGLE_MAP_API_KEY`, `GOOGLE_MAP_API_KEY_DEV`) → exposées dans le binaire et dans Git.
- Pas de **certificate pinning**.
- Token d'authentification ajouté **manuellement** par chaque appel (paramètre `requiresAuth`) → risque d'oubli, surface d'erreur élevée.
- Pas d'obfuscation activée pour les builds release.

#### Architecture
- **Router monolithique** : `lib/router/router.dart` = **1 339 lignes**. Doit être découpé par feature.
- **Pages obèses** : 9 pages > 750 lignes, record à **1 716 lignes** (`story_creator_page.dart`). Logique métier mêlée à la View → viole MVVM, intestable.
- **APIService singleton** : non injectable, donc non mockable proprement dans les tests. Affiche directement des `Fluttertoast` (couplage UI ↔ réseau).
- **`BuildContext` injecté dans `NotificationHandlerViewModel`** (`lib/main.dart`) → viole strictement la règle MVVM affichée dans `CLAUDE.md`.
- **Pas de couche Domain** (use cases, entités pures). Les ViewModels appellent directement les repositories, ce qui mélange orchestration métier et gestion d'état UI. Quand la même règle métier est utilisée par plusieurs VMs, elle est dupliquée.
- **Pas de type Result/Either** : la gestion d'erreur repose sur des `try/catch` dispersés et des chaînes de caractères dans le state.

#### Qualité & process
- **Couverture de tests partielle** : 28 VMs testés sur 39 (28 %), aucun test d'intégration, aucun golden test, aucun test de navigation.
- **Conventions de nommage incohérentes** : `*_page.dart` et `*_screen.dart` coexistent (cf. `manual_attendance_screen.dart` vs `evaluations_page.dart`).
- **Pas de CI/CD** détectable dans le repo (pas de `.github/workflows`).
- **Pas de pre-commit hook** (lint, format, test).
- **Pas de gestion d'environnements** propre : un seul `--dart-define=ENV=` qui bascule entre deux URLs en dur ; pas de flavors Android/iOS distincts.
- **`flutter_lints` 5.0** activé mais aucune règle stricte personnalisée.

#### Dépendances
- **80+ dépendances** dans `pubspec.yaml`, certaines redondantes (`http` ET `dio`, `intl: null`).
- `intl: null` est suspect, à corriger.
- `mockito` utilisé mais `mocktail` (sans codegen) est aujourd'hui le standard recommandé.

### 2.3 Synthèse de la dette
| Domaine | Niveau | Priorité refonte |
|---------|--------|------------------|
| Sécurité | 🔴 Critique | P0 — bloquant |
| Testabilité | 🟠 Élevé | P0 |
| Architecture (Domain manquant) | 🟠 Élevé | P1 |
| Router & pages géantes | 🟠 Élevé | P1 |
| CI/CD | 🟡 Moyen | P1 |
| Conventions / lint | 🟡 Moyen | P2 |
| Dépendances | 🟢 Faible | P2 |

---

## 3. Architecture cible

### 3.1 Vue d'ensemble — Clean Architecture allégée

```
┌──────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│  Pages (StatelessWidget) ──watch──▶ ViewModels (Riverpod)│
│         │                                  │             │
│         └─────────read.notifier────────────┘             │
└─────────────────────────┬────────────────────────────────┘
                          │ appelle
                          ▼
┌──────────────────────────────────────────────────────────┐
│                       DOMAIN                             │
│  UseCases (1 use case = 1 action métier)                 │
│  Entities (objets métier purs, sans dépendance Flutter)  │
│  Repository interfaces (abstract class)                  │
└─────────────────────────┬────────────────────────────────┘
                          │ implémenté par
                          ▼
┌──────────────────────────────────────────────────────────┐
│                        DATA                              │
│  Repository impl ──▶ DataSources (remote, local)         │
│  DTOs / Mappers (DTO ↔ Entity)                           │
└─────────────────────────┬────────────────────────────────┘
                          │ utilise
                          ▼
┌──────────────────────────────────────────────────────────┐
│                        CORE                              │
│  HttpClient, Storage, Logger, Result<T,F>, DI, Theme,    │
│  Router, ErrorHandling, Env                              │
└──────────────────────────────────────────────────────────┘
```

### 3.2 Règles de dépendance
- **Presentation** dépend de **Domain** uniquement (jamais de Data).
- **Domain** ne dépend de rien (pas de Flutter, pas de Dio, pas de Riverpod).
- **Data** implémente les interfaces de Domain.
- **Core** est utilisable par toutes les couches mais ne dépend d'aucune.

> ⚠️ **Le respect de cette règle est vérifié automatiquement** via une règle `import_lint` ou un test custom dans CI.

### 3.3 Pourquoi ajouter Domain ?
- Les règles métier deviennent réutilisables entre VMs (ex. `CalculateBulletinAverage` utilisé par 4 features).
- Les UseCases sont des unités testables triviales (input → output, pas de Flutter).
- Permet de remplacer la source de données (REST → GraphQL, ou ajout de cache local) sans toucher à la Presentation.

### 3.4 Gestion des erreurs — `Result<S, F>`
On bannit les `String? error` dans les states. Tous les UseCases retournent un `Result` :

```dart
sealed class Result<S, F> {
  const Result();
}
class Ok<S, F> extends Result<S, F> { final S value; const Ok(this.value); }
class Err<S, F> extends Result<S, F> { final F failure; const Err(this.failure); }
```

`F` est une `sealed class Failure` avec ses variantes (`NetworkFailure`, `UnauthorizedFailure`, `ValidationFailure(map)`, `ServerFailure(code, message)`, `UnknownFailure`).

Le ViewModel pattern-matche sur le `Result` et expose un state typé. Plus jamais de `try/catch` dans la Presentation.

---

## 4. Stack technique recommandée

| Domaine | Choix | Justification |
|---------|-------|---------------|
| **State management** | `flutter_riverpod` ^2.6 + `riverpod_generator` | Déjà en place, excellente testabilité, codegen réduit le boilerplate |
| **Navigation** | `go_router` ^14, **modulaire** (1 fichier `routes.dart` par feature) | Déjà en place, doit être découpé |
| **HTTP** | `dio` ^5 + interceptors (auth, logging, retry, error mapping) | Déjà en place |
| **Modèles** | `freezed` ^2 + `json_serializable` | Déjà en place |
| **Erreurs** | Type `Result<S,F>` maison + `sealed class Failure` | Évite `dartz`/`fpdart` (courbe d'apprentissage) tout en gardant la sûreté |
| **DI** | Riverpod uniquement (pas de `get_it`) | Une seule façon d'injecter |
| **Tests** | `flutter_test`, `mocktail` (au lieu de `mockito`), `patrol` (intégration) | `mocktail` = pas de codegen, plus simple |
| **Goldens** | `golden_toolkit` ou `alchemist` | Détecte les régressions visuelles |
| **i18n** | `slang` ^4 | Déjà en place, parfait |
| **Storage** | `flutter_secure_storage` (tokens) + `shared_preferences` (préférences non sensibles) | Déjà en place |
| **Logger** | `logger` package (au lieu de `print`) | Niveaux + filtrage prod |
| **Lint** | `very_good_analysis` ^6 (au lieu de `flutter_lints`) | Règles strictes par défaut |
| **CI** | GitHub Actions | Standard, gratuit pour repo privés Anthropic-style |
| **Code coverage** | `lcov` + Codecov ou rapport artefact CI | Visibilité |
| **Pre-commit** | `lefthook` ou `husky-dart` | Bloque les commits cassés |

### 4.1 Dépendances à supprimer / remplacer
- `http` (doublon avec `dio`).
- `intl: null` → fixer une version.
- `mockito` → `mocktail`.
- `flutter_lints` → `very_good_analysis`.
- `dartdoc` (commenté) → retirer.

---

## 5. Structure de dossiers cible

```
go4school-mobile/
├── .github/
│   └── workflows/
│       ├── ci.yml                  # analyze + test + coverage à chaque PR
│       ├── build-android.yml       # build APK + AAB sur tag
│       └── build-ios.yml           # build IPA sur tag
├── lefthook.yml                    # pre-commit / pre-push hooks
├── analysis_options.yaml           # règles lint strictes
├── pubspec.yaml
├── env/
│   ├── dev.env                     # gitignored
│   ├── staging.env                 # gitignored
│   └── prod.env                    # gitignored
├── lib/
│   ├── main_dev.dart               # entry flavor dev
│   ├── main_staging.dart
│   ├── main_prod.dart
│   ├── app/
│   │   ├── app.dart                # MaterialApp.router, ScreenUtil, theme
│   │   └── bootstrap.dart          # init() : runZonedGuarded, error handling
│   ├── core/
│   │   ├── env/
│   │   │   └── env.dart            # accès typé aux variables d'environnement
│   │   ├── network/
│   │   │   ├── http_client.dart    # Dio configuré (baseUrl, timeouts)
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart
│   │   │   │   ├── error_interceptor.dart
│   │   │   │   ├── logging_interceptor.dart
│   │   │   │   └── retry_interceptor.dart
│   │   │   ├── certificate_pinning.dart
│   │   │   └── network_info.dart   # connectivity check
│   │   ├── error/
│   │   │   ├── failure.dart        # sealed class Failure
│   │   │   ├── result.dart         # Result<S, F>
│   │   │   └── exception_mapper.dart
│   │   ├── storage/
│   │   │   ├── secure_storage.dart
│   │   │   └── preferences_storage.dart
│   │   ├── routing/
│   │   │   ├── app_router.dart     # GoRouter racine — assemble les sous-routes
│   │   │   ├── route_names.dart    # constantes de chemins
│   │   │   └── route_guards.dart   # auth guard, role guard
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_palette.dart
│   │   │   └── app_typography.dart
│   │   ├── localization/
│   │   │   └── (slang generated)
│   │   ├── widgets/                # widgets partagés (Button, TextField, ...)
│   │   ├── extensions/
│   │   ├── utils/
│   │   └── providers/              # providers transverses (locale, theme, ...)
│   └── features/
│       └── <feature_name>/
│           ├── domain/
│           │   ├── entities/
│           │   │   └── evaluation.dart
│           │   ├── repositories/
│           │   │   └── evaluations_repository.dart   # abstract
│           │   └── usecases/
│           │       ├── get_evaluations.dart
│           │       ├── create_evaluation.dart
│           │       └── assign_notes.dart
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── evaluations_remote_datasource.dart
│           │   │   └── evaluations_local_datasource.dart
│           │   ├── dtos/
│           │   │   └── evaluation_dto.dart           # freezed + json
│           │   ├── mappers/
│           │   │   └── evaluation_mapper.dart        # DTO ↔ Entity
│           │   └── repositories/
│           │       └── evaluations_repository_impl.dart
│           └── presentation/
│               ├── routes.dart                       # sous-routes go_router
│               ├── pages/
│               │   ├── evaluations_page.dart
│               │   └── create_evaluation_page.dart
│               ├── widgets/
│               ├── viewmodels/
│               │   ├── evaluations_viewmodel.dart
│               │   └── evaluations_state.dart        # freezed
│               └── providers.dart                    # riverpod providers feature-locaux
└── test/
    ├── core/                       # mirroir lib/core
    ├── features/                   # mirroir lib/features
    │   └── <feature_name>/
    │       ├── domain/usecases/
    │       ├── data/repositories/
    │       └── presentation/viewmodels/
    ├── helpers/
    │   ├── test_di.dart            # ProviderContainer factory
    │   ├── pump_app.dart           # widget test helper
    │   └── fixtures/               # JSON de test
    ├── golden/                     # tests goldens
    └── integration/                # patrol
```

---

## 6. Conventions

### 6.1 Nommage
| Type | Convention | Exemple |
|------|-----------|---------|
| Fichier écran | `*_page.dart` (jamais `_screen`) | `evaluations_page.dart` |
| ViewModel | `*_viewmodel.dart` | `evaluations_viewmodel.dart` |
| State | `*_state.dart` (freezed) | `evaluations_state.dart` |
| UseCase | verbe + nom | `get_evaluations.dart` |
| Repository interface | `*_repository.dart` | `evaluations_repository.dart` |
| Repository impl | `*_repository_impl.dart` | `evaluations_repository_impl.dart` |
| DTO | `*_dto.dart` | `evaluation_dto.dart` |
| Entity | nom métier nu | `evaluation.dart` |
| Provider | suffixe `Provider` | `evaluationsViewModelProvider` |
| Test | mirroir `_test.dart` | `evaluations_viewmodel_test.dart` |

### 6.2 Limites dures (vérifiées en CI)
- **Fichier** : ≤ 300 lignes.
- **Méthode** : ≤ 50 lignes.
- **Classe** : ≤ 250 lignes.
- **Paramètres positionnels** : ≤ 3 (au-delà, named).
- **Profondeur d'imbrication** : ≤ 4.

> Ces limites ne sont pas dogmatiques mais les dépassements doivent être justifiés en revue.

### 6.3 Règles de code
- **Aucun `print`** : utiliser `logger`.
- **Aucun `setState`** dans les pages MVVM (sauf widgets purement locaux sans logique).
- **Aucun appel HTTP** depuis une `Page` ou un `Widget`.
- **Aucun `BuildContext`** dans un ViewModel, UseCase, Repository, DataSource.
- **Aucun `import 'dart:io'`** dans `lib/features/*/presentation/` (réservé au Core).
- **Les States sont immuables** (`freezed` + `copyWith`).
- **Les UseCases retournent `Future<Result<S, Failure>>`** (jamais `throw`).
- **Pas de magic strings** : URLs dans `core/network/api_endpoints.dart`, clés de storage dans `core/storage/storage_keys.dart`.

### 6.4 `analysis_options.yaml` (extrait cible)
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "lib/core/localization/**"
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    avoid_print: error
    prefer_const_constructors: true
    require_trailing_commas: true
    sort_pub_dependencies: true
    unawaited_futures: true
```

---

## 7. Stratégie de tests

### 7.1 Pyramide cible

```
            ▲
           ╱ ╲     E2E / integration (patrol)
          ╱───╲    ~ 5 %  — golden paths critiques
         ╱     ╲
        ╱───────╲   Widget + Golden tests
       ╱         ╲  ~ 20 %
      ╱───────────╲
     ╱             ╲ Unit tests (UseCases, ViewModels, Mappers, Repos)
    ╱───────────────╲ ~ 75 %
   ─────────────────
```

### 7.2 Règles de couverture
- **Domain (UseCases)** : **100 %** couvert. C'est du code pur, sans excuse.
- **ViewModels** : **≥ 90 %**. Tous les états (loading/success/error) + toutes les actions publiques.
- **Repositories Impl** : **≥ 80 %**. Mock du datasource, on vérifie le mapping et la propagation des Failures.
- **Mappers** : **100 %** (round-trip DTO ↔ Entity).
- **Widgets / Pages** : tests d'affichage des principaux états (skeleton, vide, erreur, plein).
- **Goldens** : tous les composants partagés de `core/widgets/`.
- **Integration (Patrol)** : minimum 1 scénario par persona (login parent → consulter bulletin, login enseignant → créer une évaluation, login élève → voir l'emploi du temps).

### 7.3 Outils
```yaml
dev_dependencies:
  mocktail: ^1.0
  patrol: ^3.0
  golden_toolkit: ^0.15
  test: ^1.25
```

### 7.4 Helpers fournis dès le départ

`test/helpers/pump_app.dart` :
```dart
Future<void> pumpAppWith(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    ),
  );
}
```

`test/helpers/test_di.dart` :
```dart
ProviderContainer makeContainer({List<Override> overrides = const []}) {
  final c = ProviderContainer(overrides: overrides);
  addTearDown(c.dispose);
  return c;
}
```

### 7.5 Définition de "Done" pour chaque feature
Une feature n'est livrable que si :
- ✅ UseCases : couverts à 100 %.
- ✅ ViewModel : tous les états testés.
- ✅ Mappers testés.
- ✅ Au moins 1 widget test par page principale.
- ✅ Documentation : un `README.md` dans le dossier de la feature décrivant les UseCases et leurs entrées/sorties.
- ✅ `flutter analyze` sans warning.
- ✅ Coverage feature ≥ 80 %.

---

## 8. Sécurité

### 8.1 Actions immédiates
1. **Supprimer `MyHttpOverrides`** qui désactive la validation SSL.
2. **Sortir toutes les clés API du code** vers les fichiers `env/*.env` (gitignored) injectés via `--dart-define-from-file`.
3. **Activer le certificate pinning** sur les domaines `api.go4school.net` et `api.go4s.fr`.
4. **Centraliser le token JWT** dans `AuthInterceptor` qui l'injecte automatiquement (plus de `requiresAuth` à passer).
5. **Refresh token automatique** sur 401 (1 seul retry).
6. **Stocker tokens et données sensibles dans `flutter_secure_storage` uniquement** (jamais dans `SharedPreferences`).
7. **Activer l'obfuscation** : `flutter build apk --obfuscate --split-debug-info=build/symbols`.
8. **Désactiver les screenshots** sur les écrans sensibles (paiement, bulletins) via `FLAG_SECURE` Android et la solution équivalente iOS.

### 8.2 Gestion des secrets
- Aucun secret ne vit dans le repo.
- `env/*.env` est dans `.gitignore`.
- Un fichier `env/example.env` documente la liste des variables.
- En CI, les secrets viennent de GitHub Secrets et sont injectés au build.

### 8.3 Audit dépendances
- Activer `dart pub outdated --mode=security` dans la CI hebdomadaire.

---

## 9. CI / CD

### 9.1 Pipeline PR (`.github/workflows/ci.yml`)
À chaque pull request vers `develop` ou `main` :
1. `flutter pub get`
2. `flutter pub run build_runner build --delete-conflicting-outputs`
3. `dart format --set-exit-if-changed .`
4. `flutter analyze --fatal-infos`
5. `flutter test --coverage`
6. Vérification couverture ≥ 80 % (échec si en dessous).
7. Upload du rapport `lcov` en artefact.

### 9.2 Pipeline release
- Sur tag `v*.*.*` : build APK + AAB signé + IPA, upload sur Firebase App Distribution (staging) ou stores (prod).

### 9.3 Hooks pre-commit (`lefthook.yml`)
```yaml
pre-commit:
  parallel: true
  commands:
    format:
      run: dart format --set-exit-if-changed {staged_files}
    analyze:
      run: flutter analyze --fatal-infos
pre-push:
  commands:
    test:
      run: flutter test
```

---

## 10. Stratégie de migration

### 10.1 Approche
On **ne réécrit pas tout d'un bloc**. On reconstruit feature par feature, en parallèle de la base actuelle, sur une nouvelle branche `rebuild/main`.

### 10.2 Phasage proposé

| Phase | Durée | Livrable |
|-------|-------|----------|
| **0 — Fondations** | 1 sem | Squelette projet, CI/CD, lint, helpers de test, env, `core/` complet (network, error, storage, theme, routing) |
| **1 — Auth + Splash + Welcome** | 1 sem | Login, refresh token, secure storage, route guards |
| **2 — Home + Profil + Notification** | 1 sem | Shell de l'app, bottom nav, OneSignal proprement intégré (sans `BuildContext` dans VM) |
| **3 — Cours + PassedCourses + Schedule** | 1,5 sem | Premier flux métier complet |
| **4 — Évaluations + Notes + Bulletins** | 2 sem | Flux enseignant complet |
| **5 — Communication + Chat + Stories** | 2 sem | Flux social |
| **6 — Paiements + Support** | 1,5 sem | Flux financier (sécurité maximale) |
| **7 — Présences (daily, staff) + Incidents** | 1,5 sem | |
| **8 — Reste (Map, Exam, Suivi pédago, Promoter, Authorization, Dashboard, Absence)** | 2 sem | |
| **9 — QA + intégration + bascule** | 1 sem | Tests E2E, bêta, bascule prod |

**Total estimé : ~14 semaines** pour 1 dev senior temps plein, ou 8 semaines avec 2 devs.

### 10.3 Critères de bascule
On ne bascule la production sur la nouvelle base que si :
- ✅ 100 % du périmètre fonctionnel actuel est couvert.
- ✅ Coverage ≥ 80 %.
- ✅ Tests E2E sur 3 personas verts.
- ✅ Beta interne (1 école pilote) validée 2 semaines sans régression majeure.
- ✅ Métriques crash-free ≥ 99,5 % en bêta.

---

## 11. Annexe A — Exemple complet : feature `evaluations`

### Domain

**`lib/features/evaluations/domain/entities/evaluation.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'evaluation.freezed.dart';

@freezed
class Evaluation with _$Evaluation {
  const factory Evaluation({
    required String id,
    required String title,
    required DateTime date,
    required String courseId,
    required EvaluationType type,
  }) = _Evaluation;
}

enum EvaluationType { quiz, exam, oral, project }
```

**`lib/features/evaluations/domain/repositories/evaluations_repository.dart`**
```dart
abstract class EvaluationsRepository {
  Future<Result<List<Evaluation>, Failure>> fetchAll({required String courseId});
  Future<Result<Evaluation, Failure>> create(Evaluation evaluation);
}
```

**`lib/features/evaluations/domain/usecases/get_evaluations.dart`**
```dart
class GetEvaluations {
  GetEvaluations(this._repo);
  final EvaluationsRepository _repo;

  Future<Result<List<Evaluation>, Failure>> call({required String courseId}) {
    return _repo.fetchAll(courseId: courseId);
  }
}
```

### Data

**`lib/features/evaluations/data/dtos/evaluation_dto.dart`** — freezed + json_serializable.

**`lib/features/evaluations/data/mappers/evaluation_mapper.dart`**
```dart
extension EvaluationDtoX on EvaluationDto {
  Evaluation toEntity() => Evaluation(
    id: id,
    title: title,
    date: DateTime.parse(date),
    courseId: courseId,
    type: EvaluationType.values.byName(type),
  );
}
```

**`lib/features/evaluations/data/repositories/evaluations_repository_impl.dart`**
```dart
class EvaluationsRepositoryImpl implements EvaluationsRepository {
  EvaluationsRepositoryImpl(this._remote);
  final EvaluationsRemoteDatasource _remote;

  @override
  Future<Result<List<Evaluation>, Failure>> fetchAll({required String courseId}) async {
    try {
      final dtos = await _remote.fetchAll(courseId: courseId);
      return Ok(dtos.map((d) => d.toEntity()).toList());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }
  // ...
}
```

### Presentation

**`lib/features/evaluations/presentation/viewmodels/evaluations_state.dart`** (freezed)
```dart
@freezed
class EvaluationsState with _$EvaluationsState {
  const factory EvaluationsState.initial() = _Initial;
  const factory EvaluationsState.loading() = _Loading;
  const factory EvaluationsState.loaded(List<Evaluation> items) = _Loaded;
  const factory EvaluationsState.error(Failure failure) = _Error;
}
```

**`lib/features/evaluations/presentation/viewmodels/evaluations_viewmodel.dart`**
```dart
@riverpod
class EvaluationsViewModel extends _$EvaluationsViewModel {
  @override
  EvaluationsState build() => const EvaluationsState.initial();

  Future<void> load(String courseId) async {
    state = const EvaluationsState.loading();
    final result = await ref.read(getEvaluationsProvider).call(courseId: courseId);
    state = switch (result) {
      Ok(:final value) => EvaluationsState.loaded(value),
      Err(:final failure) => EvaluationsState.error(failure),
    };
  }
}
```

**`lib/features/evaluations/presentation/pages/evaluations_page.dart`**
```dart
class EvaluationsPage extends ConsumerWidget {
  const EvaluationsPage({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(evaluationsViewModelProvider);
    return Scaffold(
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const EvaluationsSkeleton(),
        loaded: (items) => EvaluationsList(items: items),
        error: (f) => ErrorView(failure: f, onRetry: () => ref.read(evaluationsViewModelProvider.notifier).load(courseId)),
      ),
    );
  }
}
```

### Test

**`test/features/evaluations/presentation/viewmodels/evaluations_viewmodel_test.dart`**
```dart
class _MockGetEvaluations extends Mock implements GetEvaluations {}

void main() {
  late _MockGetEvaluations getEvaluations;

  setUp(() {
    getEvaluations = _MockGetEvaluations();
  });

  ProviderContainer build() => makeContainer(overrides: [
    getEvaluationsProvider.overrideWithValue(getEvaluations),
  ]);

  test('initial state is initial', () {
    final c = build();
    expect(c.read(evaluationsViewModelProvider), const EvaluationsState.initial());
  });

  test('load → loading → loaded', () async {
    when(() => getEvaluations(courseId: 'c1'))
      .thenAnswer((_) async => Ok([_fakeEvaluation()]));

    final c = build();
    final f = c.read(evaluationsViewModelProvider.notifier).load('c1');
    expect(c.read(evaluationsViewModelProvider), const EvaluationsState.loading());
    await f;
    expect(c.read(evaluationsViewModelProvider), isA<_Loaded>());
  });

  test('load → loading → error on failure', () async {
    when(() => getEvaluations(courseId: 'c1'))
      .thenAnswer((_) async => const Err(NetworkFailure()));

    final c = build();
    await c.read(evaluationsViewModelProvider.notifier).load('c1');
    expect(c.read(evaluationsViewModelProvider), isA<_Error>());
  });
}
```

---

## 12. Annexe B — Checklist de démarrage (premier sprint)

- [ ] Créer le repo neuf, configurer GitHub branch protection sur `main` et `develop`.
- [ ] `flutter create` propre avec org bundle id corrects.
- [ ] Configurer les flavors Android (`dev`, `staging`, `prod`) + équivalent iOS.
- [ ] `analysis_options.yaml` strict (very_good_analysis).
- [ ] `lefthook.yml` + `.github/workflows/ci.yml`.
- [ ] `core/network/` complet avec interceptors testés.
- [ ] `core/error/` (Result + Failure) testé à 100 %.
- [ ] `core/storage/` (secure + prefs) testé.
- [ ] `core/routing/` squelette + auth guard.
- [ ] `core/theme/` migré depuis l'existant.
- [ ] `slang` initialisé avec les JSON migrés depuis l'existant.
- [ ] Helpers de test (`pump_app.dart`, `test_di.dart`, fixtures).
- [ ] CI verte sur le squelette vide.
- [ ] Documentation `README.md` racine : comment lancer dev / staging / prod, comment tester, comment ajouter une feature.

---

## 13. Annexe C — Anti-patterns interdits

| ❌ Interdit | ✅ À la place |
|-------------|---------------|
| `BuildContext` dans un ViewModel | Le ViewModel expose un événement, la View y réagit avec `ref.listen` |
| `try/catch` dans une page | Le ViewModel renvoie un state d'erreur typé |
| `Fluttertoast.showToast` dans une couche non-UI | Émettre une `Failure`, la View affiche le toast |
| Singleton instancié avec `MaClasse()` | Provider Riverpod injecté |
| Token passé manuellement à chaque appel | `AuthInterceptor` global |
| `print('debug')` | `logger.d('...')` |
| Page de 1000+ lignes | Découper en sous-widgets, déplacer la logique en VM/UseCase |
| `String? errorMessage` dans le state | `sealed class Failure` typée |
| Clé API en dur dans `lib/` | `--dart-define-from-file=env/prod.env` |
| `setState` dans une page MVVM | `ref.watch` sur le state du VM |

---

## 14. Annexe D — Ressources

- [Riverpod docs](https://riverpod.dev)
- [Very Good Analysis lint rules](https://pub.dev/packages/very_good_analysis)
- [Patrol — integration tests](https://patrol.leancode.co/)
- [Mocktail](https://pub.dev/packages/mocktail)
- [Flutter security best practices](https://docs.flutter.dev/deployment/obfuscate)
- [Clean Architecture in Flutter — Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/) (référence pédagogique, à adapter)

---

**Fin du document.**

Toute déviation à cette spécification doit faire l'objet d'une décision documentée (ADR) dans `docs/adr/`.
