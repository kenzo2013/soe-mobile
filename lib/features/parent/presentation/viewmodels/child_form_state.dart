import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/child.dart';

part 'child_form_state.freezed.dart';

@freezed
sealed class ChildFormState with _$ChildFormState {
  const factory ChildFormState.idle() = _Idle;
  const factory ChildFormState.saving() = _Saving;
  const factory ChildFormState.saved(Child child) = _Saved;
  const factory ChildFormState.error(Failure failure) = _Error;
}
