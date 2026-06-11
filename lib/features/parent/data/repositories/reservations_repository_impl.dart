import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/reservation_detail.dart';
import '../../domain/entities/reservation_summary.dart';
import '../../domain/repositories/reservations_repository.dart';
import '../datasources/reservations_remote_datasource.dart';
import '../dtos/parent_dashboard_dto.dart';
import '../dtos/reservation_dto.dart';

class ReservationsRepositoryImpl implements ReservationsRepository {
  const ReservationsRepositoryImpl(this._ds);
  final ReservationsRemoteDatasource _ds;

  Future<Result<T, Failure>> _guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<List<ReservationSummary>, Failure>> list() => _guard(() async {
        final dtos = await _ds.list();
        return dtos.map((e) => e.toEntity()).toList();
      });

  @override
  Future<Result<ReservationDetail, Failure>> get(String id) =>
      _guard(() async => (await _ds.get(id)).toEntity());

  @override
  Future<Result<ReservationDetail, Failure>> create(
          NewReservationParams params) =>
      _guard(() async =>
          (await _ds.create(newReservationParamsToJson(params))).toEntity());

  @override
  Future<Result<ReservationDetail, Failure>> accept(String id) =>
      _guard(() async => (await _ds.accept(id)).toEntity());

  @override
  Future<Result<ReservationDetail, Failure>> reject(String id) =>
      _guard(() async => (await _ds.reject(id)).toEntity());

  @override
  Future<Result<ReservationDetail, Failure>> negotiate(
          String id, int proposedAmount) =>
      _guard(() async => (await _ds.negotiate(id, proposedAmount)).toEntity());
}
