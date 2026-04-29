---
name: soe-viewmodel
description: Crée un ViewModel Riverpod SOE + state freezed + tests des 4 états (initial/loading/loaded/error). À utiliser pour chaque écran de feature.
---

# soe-viewmodel

Génère un `*_viewmodel.dart` + `*_state.dart` (freezed sealed) + test couvrant tous les états.

## Template state

```dart
// lib/features/<feature>/presentation/viewmodels/<name>_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soe/core/error/failure.dart';

part '<name>_state.freezed.dart';

@freezed
sealed class <Name>State with _$<Name>State {
  const factory <Name>State.initial() = _Initial;
  const factory <Name>State.loading() = _Loading;
  const factory <Name>State.loaded(<Data> data) = _Loaded;
  const factory <Name>State.error(Failure failure) = _Error;
}
```

## Template viewmodel

```dart
// lib/features/<feature>/presentation/viewmodels/<name>_viewmodel.dart
@riverpod
class <Name>ViewModel extends _$<Name>ViewModel {
  @override
  <Name>State build() => const <Name>State.initial();

  Future<void> <action>(<Input> input) async {
    state = const <Name>State.loading();
    final result = await ref.read(<usecase>Provider).call(input: input);
    state = switch (result) {
      Ok(:final value) => <Name>State.loaded(value),
      Err(:final failure) => <Name>State.error(failure),
    };
  }
}
```

## Règles dures
- **Aucun `BuildContext`** dans un ViewModel.
- **Aucun `Fluttertoast` / `showDialog` / navigation** : émettre un state, la View y réagit via `ref.listen`.
- **Aucun `try/catch`** : le UseCase renvoie un `Result`.
- **State immuable** (freezed sealed avec `switch` exhaustif).
- Couverture **≥ 90 %** : tester chaque action publique pour les 4 états.

## Test obligatoire

```dart
// test/features/<feature>/presentation/viewmodels/<name>_viewmodel_test.dart
class _MockUsecase extends Mock implements <Usecase> {}

void main() {
  late _MockUsecase usecase;

  setUp(() => usecase = _MockUsecase());

  ProviderContainer build() => makeContainer(overrides: [
    <usecase>Provider.overrideWithValue(usecase),
  ]);

  test('initial state is Initial', () {
    final c = build();
    expect(c.read(<name>ViewModelProvider), const <Name>State.initial());
  });

  test('loading -> loaded on success', () async {
    when(() => usecase(input: any(named: 'input')))
      .thenAnswer((_) async => Ok(_fake()));
    final c = build();
    final f = c.read(<name>ViewModelProvider.notifier).<action>(_fakeInput());
    expect(c.read(<name>ViewModelProvider), const <Name>State.loading());
    await f;
    expect(c.read(<name>ViewModelProvider), isA<_Loaded>());
  });

  test('loading -> error on Failure', () async {
    when(() => usecase(input: any(named: 'input')))
      .thenAnswer((_) async => const Err(NetworkFailure()));
    final c = build();
    await c.read(<name>ViewModelProvider.notifier).<action>(_fakeInput());
    expect(c.read(<name>ViewModelProvider), isA<_Error>());
  });
}
```

## Side-effects (navigation, toast)
La View utilise `ref.listen` :
```dart
ref.listen<XState>(xViewModelProvider, (prev, next) {
  next.whenOrNull(
    error: (f) => ScaffoldMessenger.of(context).showSnackBar(...),
    loaded: (_) => context.go('/next'),
  );
});
```
