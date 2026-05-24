import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/sessions_usecases.dart';
import 'sessions_states.dart';

class SessionsListViewModel extends StateNotifier<SessionsListState> {
  SessionsListViewModel(this._list) : super(const SessionsListState.initial());
  final ListSessions _list;
  Future<void> load() async {
    state = const SessionsListState.loading();
    final r = await _list();
    state = switch (r) {
      Ok(:final value) => SessionsListState.loaded(value),
      Err(:final failure) => SessionsListState.error(failure),
    };
  }

  Future<void> refresh() => load();
}

class SessionDetailViewModel extends StateNotifier<SessionDetailState> {
  SessionDetailViewModel(this._get) : super(const SessionDetailState.initial());
  final GetSessionDetail _get;
  Future<void> load(String id) async {
    state = const SessionDetailState.loading();
    final r = await _get(id);
    state = switch (r) {
      Ok(:final value) => SessionDetailState.loaded(value),
      Err(:final failure) => SessionDetailState.error(failure),
    };
  }
}
