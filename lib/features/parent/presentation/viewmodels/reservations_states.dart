import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/reservation_detail.dart';
import '../../domain/entities/reservation_summary.dart';

part 'reservations_states.freezed.dart';

@freezed
sealed class ReservationsListState with _$ReservationsListState {
  const factory ReservationsListState.initial() = _RInitial;
  const factory ReservationsListState.loading() = _RLoading;
  const factory ReservationsListState.loaded(List<ReservationSummary> items) =
      _RLoaded;
  const factory ReservationsListState.error(Failure failure) = _RError;
}

@freezed
sealed class ReservationDetailState with _$ReservationDetailState {
  const factory ReservationDetailState.initial() = _DInitial;
  const factory ReservationDetailState.loading() = _DLoading;
  const factory ReservationDetailState.loaded(ReservationDetail detail) =
      _DLoaded;
  const factory ReservationDetailState.acting() = _DActing;
  const factory ReservationDetailState.actionSuccess(ReservationDetail detail) =
      _DActionSuccess;
  const factory ReservationDetailState.error(Failure failure) = _DError;
}

@freezed
sealed class NewReservationState with _$NewReservationState {
  const factory NewReservationState.editing() = _NEditing;
  const factory NewReservationState.submitting() = _NSubmitting;
  const factory NewReservationState.submitted(ReservationDetail detail) =
      _NSubmitted;
  const factory NewReservationState.error(Failure failure) = _NError;
}
