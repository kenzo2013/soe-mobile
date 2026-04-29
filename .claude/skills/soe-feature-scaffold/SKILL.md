---
name: soe-feature-scaffold
description: Génère le squelette complet d'une feature SOE (domain/data/presentation + tests) selon REBUILD_SPEC.md §5 et §11. À invoquer dès qu'on commence une nouvelle feature métier (ex. "ajouter la feature reservations").
---

# soe-feature-scaffold

Crée la structure complète d'une nouvelle feature dans `lib/features/<feature_name>/`.

## Quand utiliser
- L'utilisateur demande une nouvelle feature ("ajoute la feature X", "implémente Y").
- Avant d'écrire du code métier, le squelette doit exister.

## Structure obligatoire à générer

```
lib/features/<feature_name>/
├── domain/
│   ├── entities/        # objets métier purs (freezed), pas d'import Flutter/Dio
│   ├── repositories/    # interfaces abstract uniquement
│   └── usecases/        # 1 fichier = 1 action métier (verbe + nom)
├── data/
│   ├── datasources/     # *_remote_datasource.dart (et *_local_datasource.dart si cache)
│   ├── dtos/            # freezed + json_serializable
│   ├── mappers/         # extension X on Dto { Entity toEntity() }
│   └── repositories/    # *_repository_impl.dart implémente l'interface domain
└── presentation/
    ├── routes.dart                      # sous-routes go_router (jamais dans le router racine)
    ├── pages/
    ├── widgets/
    ├── viewmodels/
    │   ├── *_viewmodel.dart             # @riverpod class
    │   └── *_state.dart                 # freezed sealed
    └── providers.dart                   # providers feature-locaux
```

```
test/features/<feature_name>/
├── domain/usecases/
├── data/repositories/
└── presentation/viewmodels/
```

## Règles strictes
1. **Domain ne dépend de rien** sauf `core/error/`. Aucun `import 'package:flutter'`, aucun `dio`, aucun `riverpod`.
2. **Presentation ne dépend QUE de Domain** (jamais directement de Data).
3. **Data implémente** les interfaces de Domain.
4. Tous les UseCases retournent `Future<Result<S, Failure>>` — jamais `throw`.
5. Toujours créer en parallèle un `README.md` dans le dossier de la feature listant les UseCases.
6. Nommage : `*_page.dart` (jamais `_screen`), `*_viewmodel.dart`, `*_state.dart`, `*_repository.dart` (interface), `*_repository_impl.dart` (impl), `*_dto.dart`.

## Avant de coder
- Lire `REBUILD_SPEC.md` §5 (structure) et §11 (exemple complet `evaluations`).
- Lire `docs/CAHIER_DES_CHARGES_MOBILE.docx (1).md` pour les endpoints API et règles métier de la feature.
- Lister les UseCases AVANT de générer (ex. `Login`, `Register`, `RequestPasswordReset`).
- Demander validation de la liste des UseCases à l'utilisateur si > 5.

## Après scaffold
- Invoquer `soe-usecase`, `soe-repository`, `soe-viewmodel`, `soe-page` pour remplir.
- Finir par `soe-checklist-done`.
