---
name: soe-checklist-done
description: Vérifie la "Definition of Done" SOE avant de considérer une feature livrable (REBUILD_SPEC.md §7.5). À invoquer avant de proposer un commit / PR.
---

# soe-checklist-done

Une feature SOE n'est **pas livrable** tant que tous les points ci-dessous ne sont pas verts.

## Checklist (à exécuter dans l'ordre)

### 1. Code generation à jour
```bash
dart run build_runner build --delete-conflicting-outputs && dart run slang
```
Aucune erreur. Tous les `*.freezed.dart`, `*.g.dart` à jour et committés.

### 2. Format
```bash
dart format --set-exit-if-changed .
```

### 3. Analyze
```bash
flutter analyze --fatal-infos
```
**Zéro warning, zéro info.**

### 4. Tests
```bash
flutter test --coverage
```
- ✅ Tous les tests passent.
- ✅ Coverage feature ≥ **80 %** (vérifier `coverage/lcov.info`).
- ✅ Domain UseCases : **100 %**.
- ✅ Mappers DTO↔Entity : **100 %** (round-trip).
- ✅ ViewModels : tous les états (initial/loading/loaded/error) testés.
- ✅ Repositories Impl : ≥ 80 %, codes HTTP mappés (400/401/403/404/409/422/5xx) testés.
- ✅ Au moins 1 widget test par page principale (skeleton/loaded/error+retry).

### 5. Design system, textes, règle 0
```bash
python3 tools/ds_guard.py --check
python3 tools/ds_guard.py --files $(git diff --name-only refonte/v2 -- 'lib/*.dart')
```
- ✅ Aucun seuil dépassé ; **aucune occurrence dans les fichiers créés** par la tâche.
- ✅ Textes FR et EN ajoutés ensemble, `dart run slang` relancé.
- ✅ Code, commentaires, fichiers en anglais.
- ✅ Écran comparé au Studio sur simulateur à 390 et 834 (captures dans le rendu).
- ✅ `soe-a11y-audit` passé sur les écrans créés.
- ✅ Testé contre le serveur Rails **local**, jamais staging ni production.

### 5bis. Conventions
- ✅ Aucun fichier > 300 lignes (sauf justifié et documenté).
- ✅ Aucune méthode > 50 lignes.
- ✅ Aucun `print` (utiliser `logger`).
- ✅ Aucun `BuildContext` dans VM/UseCase/Repo/DataSource.
- ✅ Aucun `try/catch` dans Presentation.
- ✅ Aucune clé API en dur.
- ✅ Aucun `setState` dans une page MVVM.
- ✅ Aucun `StateNotifier` ajouté ; ceux des écrans touchés migrés.
- ✅ Tous les fichiers de pages : `*_page.dart` (jamais `*_screen.dart`).

### 6. Architecture
- ✅ Domain n'importe ni `flutter`, ni `dio`, ni `riverpod`.
- ✅ Presentation n'importe pas `data/`.
- ✅ DataSource throw, Repository convertit en `Failure`.
- ✅ Tous les UseCases retournent `Future<Result<S, Failure>>`.

### 7. Documentation
- ✅ `README.md` dans `lib/features/<feature>/` listant :
  - Endpoints API consommés
  - UseCases + signatures
  - Diagramme de flow si non-trivial
- ✅ Toute déviation au spec : ADR créé dans `docs/adr/NNNN-<titre>.md`.

### 8. Sécurité
- ✅ Tokens uniquement dans `flutter_secure_storage`.
- ✅ Aucun secret committé (vérifier `git diff` contre `env/example.env`).
- ✅ Pas de log de PII (mots de passe, tokens, numéros de tel).

### 9. Routes
- ✅ Routes définies dans `<feature>/presentation/routes.dart`, pas dans le router racine.
- ✅ Noms dans `RouteNames`, pas en dur.
- ✅ Auth/role guards appliqués si pertinent.

## Si une case échoue
Ne pas commit. Corriger d'abord. Si correction impossible dans le sprint actuel : créer une issue + commenter `// TODO(soe): <ref>` dans le code et mentionner explicitement la dette dans le PR.
