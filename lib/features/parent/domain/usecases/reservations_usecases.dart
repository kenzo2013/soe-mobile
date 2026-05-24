import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/reservation_detail.dart';
import '../entities/reservation_summary.dart';
import '../repositories/reservations_repository.dart';

class ListReservations {
  const ListReservations(this._r);
  final ReservationsRepository _r;
  Future<Result<List<ReservationSummary>, Failure>> call() => _r.list();
}

class GetReservationDetail {
  const GetReservationDetail(this._r);
  final ReservationsRepository _r;
  Future<Result<ReservationDetail, Failure>> call(String id) => _r.get(id);
}

class CreateReservation {
  const CreateReservation(this._r);
  final ReservationsRepository _r;
  Future<Result<ReservationDetail, Failure>> call(NewReservationParams p) =>
      _r.create(p);
}

class AcceptReservation {
  const AcceptReservation(this._r);
  final ReservationsRepository _r;
  Future<Result<ReservationDetail, Failure>> call(String id) => _r.accept(id);
}

class RejectReservation {
  const RejectReservation(this._r);
  final ReservationsRepository _r;
  Future<Result<ReservationDetail, Failure>> call(String id) => _r.reject(id);
}

class NegotiateReservation {
  const NegotiateReservation(this._r);
  final ReservationsRepository _r;
  Future<Result<ReservationDetail, Failure>> call(
          String id, int proposedAmount) =>
      _r.negotiate(id, proposedAmount);
}
