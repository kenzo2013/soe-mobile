import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/reservation_detail.dart';
import '../../domain/usecases/reservations_usecases.dart';
import 'reservations_states.dart';

class ReservationsListViewModel extends StateNotifier<ReservationsListState> {
  ReservationsListViewModel(this._list)
      : super(const ReservationsListState.initial());
  final ListReservations _list;

  Future<void> load() async {
    state = const ReservationsListState.loading();
    final r = await _list();
    state = switch (r) {
      Ok(:final value) => ReservationsListState.loaded(value),
      Err(:final failure) => ReservationsListState.error(failure),
    };
  }

  Future<void> refresh() => load();
}

class ReservationDetailViewModel extends StateNotifier<ReservationDetailState> {
  ReservationDetailViewModel({
    required this.getDetail,
    required this.accept,
    required this.reject,
    required this.negotiate,
  }) : super(const ReservationDetailState.initial());

  final GetReservationDetail getDetail;
  final AcceptReservation accept;
  final RejectReservation reject;
  final NegotiateReservation negotiate;

  Future<void> load(String id) async {
    state = const ReservationDetailState.loading();
    final r = await getDetail(id);
    state = switch (r) {
      Ok(:final value) => ReservationDetailState.loaded(value),
      Err(:final failure) => ReservationDetailState.error(failure),
    };
  }

  Future<void> doAccept(String id) => _act(() => accept(id));
  Future<void> doReject(String id) => _act(() => reject(id));
  Future<void> doNegotiate(String id, int amount) =>
      _act(() => negotiate(id, amount));

  Future<void> _act(
      Future<Result<ReservationDetail, Failure>> Function() body) async {
    state = const ReservationDetailState.acting();
    final r = await body();
    state = switch (r) {
      Ok(:final value) => ReservationDetailState.actionSuccess(value),
      Err(:final failure) => ReservationDetailState.error(failure),
    };
  }
}

class NewReservationViewModel extends StateNotifier<NewReservationState> {
  NewReservationViewModel(this._create)
      : super(const NewReservationState.editing());
  final CreateReservation _create;

  Future<void> submit(NewReservationParams params) async {
    state = const NewReservationState.submitting();
    final r = await _create(params);
    state = switch (r) {
      Ok(:final value) => NewReservationState.submitted(value),
      Err(:final failure) => NewReservationState.error(failure),
    };
  }

  void reset() => state = const NewReservationState.editing();
}
