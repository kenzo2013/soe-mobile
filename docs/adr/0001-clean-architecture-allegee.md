# ADR 0001 — Clean Architecture allégée

- Statut : accepté
- Date : 2026-04-29

## Contexte
La base précédente mélangeait logique métier et UI (pages > 1500 lignes, BuildContext dans les ViewModels, gestion d'erreur via String). Cf. `REBUILD_SPEC.md` §2.

## Décision
Adopter une Clean Architecture en 3 couches (Domain / Data / Presentation) + Core transverse, avec :
- `Result<S, Failure>` maison (pas de `dartz`/`fpdart`).
- Riverpod comme seule DI/state.
- `go_router` modulaire (1 `routes.dart` par feature).
- `freezed` + `json_serializable` pour DTO et states.
- `mocktail` (sans codegen) pour les tests.
- `very_good_analysis` pour le lint.

## Conséquences
+ Testabilité maximale ; Domain 100 % couvert.
+ Coût d'une feature ≤ 3 jours.
- Plus de boilerplate qu'une archi plate (mappers DTO↔Entity).
- Equipe doit respecter strictement les frontières (vérifié par `soe-anti-patterns`).
