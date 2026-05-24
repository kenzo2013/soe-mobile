import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/child.dart';

part 'children_list_state.freezed.dart';

@freezed
sealed class ChildrenListState with _$ChildrenListState {
  const factory ChildrenListState.initial() = _Initial;
  const factory ChildrenListState.loading() = _Loading;
  const factory ChildrenListState.loaded(List<Child> children) = _Loaded;
  const factory ChildrenListState.error(Failure failure) = _Error;
}
