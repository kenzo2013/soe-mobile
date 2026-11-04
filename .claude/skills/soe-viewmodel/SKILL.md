---
name: soe-viewmodel
description: Crée un ViewModel Riverpod SOE (Notifier pour une action ou un formulaire, AsyncNotifier pour charger des données) avec son state freezed et ses tests. À utiliser pour chaque écran de feature, et pour migrer un StateNotifier quand on touche l'écran.
---

# soe-viewmodel

**Décision v2** : `Notifier` / `AsyncNotifier` de Riverpod 2.6, providers déclarés à la main
(pas de `@riverpod`, pas de code généré pour les providers). `StateNotifier` est l'ancien style :
on n'en écrit plus, et on migre celui de l'écran qu'on modifie.

| Besoin | Classe | State |
|---|---|---|
| Action ou formulaire (connexion, envoi d'un PV, acceptation d'un devis) | `AutoDisposeNotifier<XState>` | freezed sealed : `initial` / `loading` / `success` / `error(Failure)` |
| Charger des données (liste, détail, tableau de bord) | `AutoDisposeAsyncNotifier<T>` (ou `AutoDisposeFamilyAsyncNotifier<T, Arg>`) | `AsyncValue<T>`, l'erreur est une `Failure` |

## Action ou formulaire — `Notifier`

```dart
// lib/features/<feature>/presentation/viewmodels/<name>_state.dart
@freezed
sealed class AcceptQuoteState with _$AcceptQuoteState {
  const factory AcceptQuoteState.initial() = AcceptQuoteInitial;
  const factory AcceptQuoteState.loading() = AcceptQuoteLoading;
  const factory AcceptQuoteState.success(Quote quote) = AcceptQuoteSuccess;
  const factory AcceptQuoteState.error(Failure failure) = AcceptQuoteError;
}

// lib/features/<feature>/presentation/viewmodels/<name>_viewmodel.dart
final acceptQuoteViewModelProvider =
    NotifierProvider.autoDispose<AcceptQuoteViewModel, AcceptQuoteState>(
  AcceptQuoteViewModel.new,
);

class AcceptQuoteViewModel extends AutoDisposeNotifier<AcceptQuoteState> {
  @override
  AcceptQuoteState build() => const AcceptQuoteState.initial();

  Future<void> accept(String quoteId) async {
    if (state is AcceptQuoteLoading) return; // no double submit
    state = const AcceptQuoteState.loading();
    final result = await ref.read(acceptQuoteUsecaseProvider).call(quoteId: quoteId);
    state = switch (result) {
      Ok(:final value) => AcceptQuoteState.success(value),
      Err(:final failure) => AcceptQuoteState.error(failure),
    };
  }
}
```

## Charger des données — `AsyncNotifier`

```dart
final quotesViewModelProvider =
    AsyncNotifierProvider.autoDispose<QuotesViewModel, List<Quote>>(QuotesViewModel.new);

class QuotesViewModel extends AutoDisposeAsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() async {
    final result = await ref.watch(getQuotesUsecaseProvider).call();
    // The only place a Failure is thrown: AsyncValue captures it as AsyncError(failure).
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Quote>>().copyWithPrevious(state);
    state = await AsyncValue.guard(build);
  }
}
```

La page lit `state.when(data:, loading:, error: (e, _) => ErrorView(failure: e as Failure, …))`.
`Failure` est une classe : le `throw` ci-dessus est le **seul** usage autorisé, dans `build`
d'un `AsyncNotifier`, pour alimenter `AsyncValue`.

## Migrer un `StateNotifier`

1. `extends StateNotifier<S>` + constructeur `super(initial)` → `extends AutoDisposeNotifier<S>`
   + `S build() => initial`.
2. `final Ref _ref` → `ref` hérité ; supprimer le constructeur.
3. `StateNotifierProvider.autoDispose<V, S>(V.new)` → `NotifierProvider.autoDispose<V, S>(V.new)`.
4. Les tests passent sans changement de comportement ; `ds_guard` voit `state_notifier` baisser.

## Règles dures
- Aucun `BuildContext`, aucune navigation, aucun toast, aucun dialogue dans un view model :
  il émet un state, la page réagit avec `ref.listen`.
- Aucun `try/catch` : le use case renvoie un `Result`.
- `ref.watch` dans `build`, `ref.read` dans les méthodes.
- Protection contre le double envoi sur toute action réseau.
- State immuable, `switch` exhaustif côté page.

## Tests obligatoires

```dart
test('loading then success', () async {
  when(() => usecase(quoteId: any(named: 'quoteId'))).thenAnswer((_) async => Ok(fakeQuote));
  final container = makeContainer(overrides: [acceptQuoteUsecaseProvider.overrideWithValue(usecase)]);
  final sub = container.listen(acceptQuoteViewModelProvider, (_, __) {});

  final future = container.read(acceptQuoteViewModelProvider.notifier).accept('q1');
  expect(sub.read(), const AcceptQuoteState.loading());
  await future;
  expect(sub.read(), AcceptQuoteState.success(fakeQuote));
});
```

Chaque action : `initial`, `loading`, `success`, chaque `Failure` utile, double envoi ignoré.
Chaque `AsyncNotifier` : données, erreur, `refresh`. Garder le provider vivant avec
`container.listen` (sinon `autoDispose` le détruit pendant le test).
