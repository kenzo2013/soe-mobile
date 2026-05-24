import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/child.dart';
import '../../domain/usecases/save_child.dart';
import 'child_form_state.dart';

class ChildFormViewModel extends StateNotifier<ChildFormState> {
  ChildFormViewModel(this._save) : super(const ChildFormState.idle());
  final SaveChild _save;

  Future<void> submit({String? id, required ChildFormParams params}) async {
    state = const ChildFormState.saving();
    final r = await _save(id: id, params: params);
    state = switch (r) {
      Ok(:final value) => ChildFormState.saved(value),
      Err(:final failure) => ChildFormState.error(failure),
    };
  }

  void reset() => state = const ChildFormState.idle();
}
