import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';

/// États génériques réutilisés par tous les écrans tuteur orientés données.
///
/// On préfère ces sealed classes faites main (avec `.when`) à un union freezed
/// générique : freezed ne génère pas de `when` pour les types paramétrés, et la
/// feature `parent` a déjà établi ce pattern (`AsyncListState`). Les pages
/// gardent l'idiome `state.when(...)`, les ViewModels restent sans
/// `BuildContext`, et le mapping `Result` -> état se fait par `switch`.

// ── Liste ────────────────────────────────────────────────────
sealed class AsyncListState<T> {
  const AsyncListState();

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(List<T> items) loaded,
    required R Function(Failure failure) error,
  }) {
    final self = this;
    return switch (self) {
      AsyncListInitial<T>() => initial(),
      AsyncListLoading<T>() => loading(),
      AsyncListLoaded<T>(:final items) => loaded(items),
      AsyncListError<T>(:final failure) => error(failure),
    };
  }
}

class AsyncListInitial<T> extends AsyncListState<T> {
  const AsyncListInitial();
}

class AsyncListLoading<T> extends AsyncListState<T> {
  const AsyncListLoading();
}

class AsyncListLoaded<T> extends AsyncListState<T> {
  const AsyncListLoaded(this.items);
  final List<T> items;
}

class AsyncListError<T> extends AsyncListState<T> {
  const AsyncListError(this.failure);
  final Failure failure;
}

// ── Élément unique ───────────────────────────────────────────
sealed class AsyncItemState<T> {
  const AsyncItemState();

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T item) loaded,
    required R Function(Failure failure) error,
  }) {
    final self = this;
    return switch (self) {
      AsyncItemInitial<T>() => initial(),
      AsyncItemLoading<T>() => loading(),
      AsyncItemLoaded<T>(:final item) => loaded(item),
      AsyncItemError<T>(:final failure) => error(failure),
    };
  }
}

class AsyncItemInitial<T> extends AsyncItemState<T> {
  const AsyncItemInitial();
}

class AsyncItemLoading<T> extends AsyncItemState<T> {
  const AsyncItemLoading();
}

class AsyncItemLoaded<T> extends AsyncItemState<T> {
  const AsyncItemLoaded(this.item);
  final T item;
}

class AsyncItemError<T> extends AsyncItemState<T> {
  const AsyncItemError(this.failure);
  final Failure failure;
}

// ── Base ViewModels génériques ───────────────────────────────
/// VM de liste : charge via un `fetch` renvoyant un `Result`.
class AsyncListViewModel<T> extends StateNotifier<AsyncListState<T>> {
  AsyncListViewModel(this._fetch) : super(AsyncListInitial<T>());
  final Future<Result<List<T>, Failure>> Function() _fetch;

  Future<void> load() async {
    state = AsyncListLoading<T>();
    final r = await _fetch();
    state = switch (r) {
      Ok(:final value) => AsyncListLoaded<T>(value),
      Err(:final failure) => AsyncListError<T>(failure),
    };
  }

  Future<void> refresh() => load();
}

/// VM d'élément unique paramétré par un identifiant.
class AsyncItemViewModel<T> extends StateNotifier<AsyncItemState<T>> {
  AsyncItemViewModel(this._fetch) : super(AsyncItemInitial<T>());
  final Future<Result<T, Failure>> Function(String id) _fetch;

  Future<void> load(String id) async {
    state = AsyncItemLoading<T>();
    final r = await _fetch(id);
    state = switch (r) {
      Ok(:final value) => AsyncItemLoaded<T>(value),
      Err(:final failure) => AsyncItemError<T>(failure),
    };
  }
}

// ── Action (formulaires / mutations) ─────────────────────────
sealed class TutorActionState {
  const TutorActionState();

  R when<R>({
    required R Function() idle,
    required R Function() submitting,
    required R Function() success,
    required R Function(Failure failure) error,
  }) {
    final self = this;
    return switch (self) {
      TutorActionIdle() => idle(),
      TutorActionSubmitting() => submitting(),
      TutorActionSuccess() => success(),
      TutorActionError(:final failure) => error(failure),
    };
  }
}

class TutorActionIdle extends TutorActionState {
  const TutorActionIdle();
}

class TutorActionSubmitting extends TutorActionState {
  const TutorActionSubmitting();
}

class TutorActionSuccess extends TutorActionState {
  const TutorActionSuccess();
}

class TutorActionError extends TutorActionState {
  const TutorActionError(this.failure);
  final Failure failure;
}

/// VM générique de mutation : expose `idle/submitting/success/error`.
/// La View réagit au succès via `ref.listen` (pop, refresh, toast).
class TutorActionViewModel extends StateNotifier<TutorActionState> {
  TutorActionViewModel() : super(const TutorActionIdle());

  bool get isSubmitting => state is TutorActionSubmitting;

  /// Exécute une mutation. Retourne `true` en cas de succès.
  ///
  /// Les actions « fire-and-forget » (ex. suppression depuis une liste) ne sont
  /// observées par aucun `Consumer` : le provider `autoDispose` peut donc être
  /// recyclé pendant l'`await op()`. On garde les mutations d'état derrière
  /// `mounted` pour éviter « Tried to use … after dispose » — le résultat
  /// booléen reste correct et la View pilote toast + refresh.
  Future<bool> run(Future<Result<void, Failure>> Function() op) async {
    if (state is TutorActionSubmitting) return false;
    state = const TutorActionSubmitting();
    final r = await op();
    return switch (r) {
      Ok() => () {
          if (mounted) state = const TutorActionSuccess();
          return true;
        }(),
      Err(:final failure) => () {
          if (mounted) state = TutorActionError(failure);
          return false;
        }(),
    };
  }

  void reset() => state = const TutorActionIdle();
}

/// VM d'objet unique sans identifiant (dashboard, profil, rémunérations).
class AsyncObjectViewModel<T> extends StateNotifier<AsyncItemState<T>> {
  AsyncObjectViewModel(this._fetch) : super(AsyncItemInitial<T>());
  final Future<Result<T, Failure>> Function() _fetch;

  Future<void> load() async {
    state = AsyncItemLoading<T>();
    final r = await _fetch();
    state = switch (r) {
      Ok(:final value) => AsyncItemLoaded<T>(value),
      Err(:final failure) => AsyncItemError<T>(failure),
    };
  }

  Future<void> refresh() => load();
}
