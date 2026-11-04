---
name: soe-anti-patterns
description: Audite des fichiers SOE modifiés contre la liste d'anti-patterns interdits (REBUILD_SPEC.md §13, design system, décisions v2, règle 0). À invoquer avant review / commit.
---

# soe-anti-patterns

Scanne les fichiers du périmètre courant et signale les violations.

## Méthode d'exécution
1. Identifier les fichiers modifiés par la tâche : `git diff --name-only refonte/v2`.
2. Filtrer `.dart` sous `lib/`.
3. Pour chaque fichier, rechercher les patterns ci-dessous via `grep`.
4. Reporter chaque violation avec `file:line` + suggestion de correctif.

## Patterns à détecter

| Pattern grep | Diagnostic | Correctif |
|---|---|---|
| `BuildContext` dans `viewmodels/`, `usecases/`, `repositories/`, `datasources/` | Couplage UI ↔ logique | Émettre un state, View réagit via `ref.listen` |
| `try {` dans `presentation/` (hors widgets purement locaux) | Erreurs gérées hors VM | Le VM expose `error(Failure)`, la page lit le state |
| `Fluttertoast` ou `showSnackBar` dans `viewmodels/`, `usecases/`, `repositories/` | Couche non-UI affiche UI | Émettre une `Failure`, View affiche le toast |
| `showSnackBar` / `SnackBar(` **n'importe où** hors `core/widgets/` | Toast hors design system | `SoeToast.show(...)` |
| `StateNotifier` / `StateNotifierProvider` dans du code nouveau ou modifié | Ancien style (décision v2) | `Notifier` / `AsyncNotifier` (skill `soe-viewmodel`) |
| `fontSize:`, `TextStyle(`, `Color(0x`, `Colors.x`, `EdgeInsets.all(13)` dans une feature | Contourne les tokens | `AppTypography` / `AppPalette` / `AppSpacing` |
| `ElevatedButton`, `TextField(`, `showDialog` dans une feature | Material brut | `SoeButton`, `SoeTextField`, `SoeConfirmDialog` |
| `LinearGradient(`, `BoxShadow(` décoratif | Contraire à la DA v2 | Surface plate `AppPalette` |
| `Text('…')` avec un littéral | Texte en dur | `Translations.of(context).x` |
| `.w`, `.h`, `.sp` (flutter_screenutil) | Dépendance abandonnée | Tokens + `LayoutBuilder` |
| Identifiant, commentaire ou nom de fichier en français | Règle 0 | Renommer en anglais |
| URL `jeteste.site` ou de production dans `lib/` ou un test | Données de test hors local | `env/*.env`, serveur local |
| `print(` | Pas de logger | `logger.d('...')` |
| `setState(` dans `*_page.dart` | Viole MVVM | `ref.watch(viewModelProvider)` |
| `dartz` ou `fpdart` import | Stack non-officielle | Utiliser `Result<S,F>` maison |
| `MaClasse()` instancié en dur dans une page | Pas de DI | Provider Riverpod |
| `requiresAuth:` / token passé manuellement | Auth non centralisée | `AuthInterceptor` global |
| `String? errorMessage` ou `String? error` dans un state | Erreur non typée | `Failure?` ou `sealed Failure` |
| Clé API ou secret littéral (`AIza`, `sk_`, `pk_live_`) dans `lib/` | Secret en dur | `--dart-define-from-file=env/X.env` |
| `import 'package:flutter/...'` dans `lib/features/*/domain/` | Domain dépend de Flutter | Retirer, déplacer en Presentation |
| `import 'package:dio/...'` dans `lib/features/*/domain/` | Domain dépend de Dio | Retirer |
| `import 'package:flutter_riverpod/...'` dans `lib/features/*/domain/` | Domain dépend de Riverpod | Provider en Presentation uniquement |
| `import 'package:soe/features/*/data/'` dans `presentation/` | Presentation skip Domain | Importer Domain |
| `*_screen.dart` | Convention violée | Renommer `*_page.dart` |
| `MyHttpOverrides` ou `badCertificateCallback.*=>.*true` | SSL désactivé | Supprimer, activer cert pinning |
| Fichier > 300 lignes (`wc -l`) | Limite dure dépassée | Découper en sous-widgets |
| Méthode > 50 lignes | Limite dure dépassée | Extraire des fonctions privées |

## Commandes de scan rapide
```bash
# Design system, StateNotifier, textes en dur (fichiers modifiés)
python3 tools/ds_guard.py --diff refonte/v2        # files that got worse
python3 tools/ds_guard.py --files <file.dart>     # every hit of one file

# BuildContext en couches non-UI
grep -rn "BuildContext" lib/features/*/domain/ lib/features/*/data/ lib/features/*/presentation/viewmodels/ 2>/dev/null

# print() partout dans lib/
grep -rn "print(" lib/

# screen vs page
find lib/ -name "*_screen.dart"

# Imports interdits dans Domain
grep -rln "package:flutter\|package:dio\|package:flutter_riverpod" lib/features/*/domain/

# Imports data/ depuis presentation/
grep -rln "lib/features/.*/data/" lib/features/*/presentation/

# Tailles
find lib/ -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" -exec wc -l {} \; | awk '$1 > 300'
```

## Output attendu
Un tableau Markdown :
```
| Fichier | Ligne | Violation | Correctif |
|---|---|---|---|
| lib/features/x/presentation/pages/y_page.dart | 42 | try/catch en page | Déplacer en VM |
```

Si aucune violation : afficher `✅ Aucun anti-pattern détecté.`.
