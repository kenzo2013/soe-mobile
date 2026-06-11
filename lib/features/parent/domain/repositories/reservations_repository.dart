import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/reservation_detail.dart';
import '../entities/reservation_summary.dart';

abstract interface class ReservationsRepository {
  Future<Result<List<ReservationSummary>, Failure>> list();
  Future<Result<ReservationDetail, Failure>> get(String id);
  Future<Result<ReservationDetail, Failure>> create(
      NewReservationParams params);
  Future<Result<ReservationDetail, Failure>> accept(String id);
  Future<Result<ReservationDetail, Failure>> reject(String id);
  Future<Result<ReservationDetail, Failure>> negotiate(
      String id, int proposedAmount);
}
