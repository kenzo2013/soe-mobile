---
name: soe-api-v2
description: Consommer un endpoint de l'API v2 SOE (enveloppe { data, meta, errors }, codes d'erreur, pagination, langue, fichiers signés) dans un datasource et un repository Flutter. À utiliser pour tout appel à /api/v2.
---

# Consommer l'API v2

Le contrat est défini côté Rails (`soe/docs/api/v2/openapi.yml`, agent `api-doc`). Le socle
(client v2, parsing de l'enveloppe, correspondance des erreurs) est construit à la tâche 0.6 ;
cette skill décrit la cible.

## Contrat

```json
{ "data": { … } | [ … ], "meta": { "page": 1, "per_page": 20, "total_count": 57, "total_pages": 3 } }
{ "errors": [ { "code": "invalid", "message": "…", "field": "amount" } ] }
```

| HTTP | `errors[].code` | `Failure` |
|---|---|---|
| 401 | `unauthenticated` | `UnauthorizedFailure` (l'intercepteur tente le renouvellement, puis déconnecte) |
| 403 | `forbidden` | `ForbiddenFailure` |
| 404 | `not_found` | `NotFoundFailure` |
| 409 | `conflict` | `ConflictFailure(message)` |
| 422 | `invalid` + `field` | `ValidationFailure(errors par champ, message)` |
| 429 | `rate_limited` | `RateLimitedFailure` (à créer en 0.6) |
| 5xx, réseau, délai | — | `ServerFailure` / `NetworkFailure` / `TimeoutFailure` |

- Le statut HTTP fait foi ; il n'y a plus de `status.code` dans le corps (c'était la v1).
- `message` est déjà traduit par le serveur (`Accept-Language`, posé par `LocaleInterceptor`) :
  l'afficher tel quel pour 409 et 422 ; pour les autres, le texte vient de `failureMessage`.
- Dates ISO 8601 avec fuseau → `DateTime.parse(...).toLocal()` ; montants en FCFA **entiers** (`int`).
- Fichiers : `has_file` + appel à l'endpoint de téléchargement qui renvoie une URL signée
  valable 15 minutes. Ne jamais stocker cette URL.

## Datasource

```dart
class QuotesRemoteDatasource {
  const QuotesRemoteDatasource(this._dio);
  final Dio _dio;

  Future<Paginated<QuoteDto>> fetchQuotes({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpointsV2.parentQuotes,
      queryParameters: {'page': page},
    );
    return Paginated.fromEnvelope(response.data!, QuoteDto.fromJson);
  }
}
```

`Paginated<T>` (items + `page`, `totalPages`, `hasMore`) et `Paginated.fromEnvelope` sont dans
`lib/core/network/` (tâche 0.6). Pas `Page<T>` : ce nom existe déjà dans Flutter et go_router.
Le repository convertit `DioException` → `Failure` via `ExceptionMapper.fromDio`
(skill `soe-repository`), qui lit `errors[]` du corps v2.

## Règles
- Chemins dans `ApiEndpointsV2`, jamais en dur ; noms en anglais.
- La base URL et la version viennent de `env/*.env`. ⚠️ Aujourd'hui `Env.apiBaseUrl` vaut
  **staging** par défaut s'il manque dans le fichier d'environnement : toujours lancer avec
  `--dart-define-from-file=env/dev.env` pointant sur le serveur **local** (correction prévue en 0.6).
- Listes : pagination par défilement (charger la page suivante à 80 % de la liste), jamais tout charger.
- Champ inconnu ignoré, champ manquant toléré (`@Default`) : une app publiée doit survivre à
  l'ajout d'un champ côté serveur.
- Tests du repository : un test par ligne du tableau d'erreurs, avec des JSON d'exemple tirés
  de la spec OpenAPI.
