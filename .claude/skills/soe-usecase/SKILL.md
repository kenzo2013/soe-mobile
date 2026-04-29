---
name: soe-usecase
description: Crée un UseCase Domain SOE et son test à 100 %. Utiliser dès qu'on ajoute une action métier (ex. "ajoute le UseCase Login").
---

# soe-usecase

Génère un UseCase pur (sans Flutter) + test couvrant succès et chaque variante de `Failure`.

## Template UseCase

```dart
// lib/features/<feature>/domain/usecases/<verb>_<noun>.dart
import 'package:soe/core/error/failure.dart';
import 'package:soe/core/error/result.dart';
import 'package:soe/features/<feature>/domain/entities/<entity>.dart';
import 'package:soe/features/<feature>/domain/repositories/<feature>_repository.dart';

class <VerbNoun> {
  const <VerbNoun>(this._repo);
  final <Feature>Repository _repo;

  Future<Result<<Output>, Failure>> call({required <Input> input}) {
    // validation pré-appel ici si besoin (retourner Err(ValidationFailure(...)) directement)
    return _repo.<method>(input);
  }
}
```

## Règles
- **Une classe = une méthode `call`** (callable).
- **Toujours `Future<Result<S, Failure>>`** — jamais `throw`.
- Les paramètres positionnels ≤ 3 (au-delà : named).
- Pas d'`import 'package:flutter/...'`, pas de `dio`, pas de `BuildContext`.
- Provider Riverpod associé dans `presentation/providers.dart` :
  ```dart
  @riverpod
  <VerbNoun> <verbNoun>(<VerbNoun>Ref ref) =>
      <VerbNoun>(ref.watch(<feature>RepositoryProvider));
  ```

## Test obligatoire (couverture 100 %)

```dart
// test/features/<feature>/domain/usecases/<verb>_<noun>_test.dart
class _MockRepo extends Mock implements <Feature>Repository {}

void main() {
  late _MockRepo repo;
  late <VerbNoun> usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = <VerbNoun>(repo);
  });

  test('returns Ok when repo succeeds', () async {
    when(() => repo.<method>(any())).thenAnswer((_) async => Ok(_fakeOutput()));
    final r = await usecase(input: _fakeInput());
    expect(r, isA<Ok<<Output>, Failure>>());
  });

  test('propagates NetworkFailure', () async {
    when(() => repo.<method>(any())).thenAnswer((_) async => const Err(NetworkFailure()));
    final r = await usecase(input: _fakeInput());
    expect(r, const Err<<Output>, Failure>(NetworkFailure()));
  });

  // Ajouter un test par variante de Failure pertinente :
  // UnauthorizedFailure, ValidationFailure, ServerFailure, UnknownFailure
}
```

## Anti-patterns interdits
- `try/catch` dans un UseCase (le repo gère déjà la conversion en Failure).
- Appeler plusieurs repos depuis un UseCase orchestrateur sans passer par une méthode repo dédiée — préférer un UseCase composite explicite.
- Laisser fuiter une `DioException` ou tout autre type d'exception réseau hors de Domain.
