import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/session_detail.dart';
import '../../domain/entities/session_summary.dart';

part 'sessions_states.freezed.dart';

@freezed
sealed class SessionsListState with _$SessionsListState {
  const factory SessionsListState.initial() = _SLInit;
  const factory SessionsListState.loading() = _SLLoading;
  const factory SessionsListState.loaded(List<SessionSummary> items) =
      _SLLoaded;
  const factory SessionsListState.error(Failure failure) = _SLError;
}

@freezed
sealed class SessionDetailState with _$SessionDetailState {
  const factory SessionDetailState.initial() = _SDInit;
  const factory SessionDetailState.loading() = _SDLoading;
  const factory SessionDetailState.loaded(SessionDetail detail) = _SDLoaded;
  const factory SessionDetailState.error(Failure failure) = _SDError;
}
