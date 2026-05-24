import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/list_children.dart';
import 'children_list_state.dart';

class ChildrenListViewModel extends StateNotifier<ChildrenListState> {
  ChildrenListViewModel(this._list) : super(const ChildrenListState.initial());

  final ListChildren _list;

  Future<void> load() async {
    state = const ChildrenListState.loading();
    final r = await _list();
    state = switch (r) {
      Ok(:final value) => ChildrenListState.loaded(value),
      Err(:final failure) => ChildrenListState.error(failure),
    };
  }

  Future<void> refresh() => load();
}
