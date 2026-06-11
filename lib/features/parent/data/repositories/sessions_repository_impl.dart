import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/session_detail.dart';
import '../../domain/entities/session_summary.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_datasource.dart';
import '../dtos/parent_dashboard_dto.dart';
import '../dtos/session_detail_dto.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  const SessionsRepositoryImpl(this._ds);
  final SessionsRemoteDatasource _ds;

  Future<Result<T, Failure>> _guard<T>(Future<T> Function() body) async {
    try {
      return Ok(await body());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<List<SessionSummary>, Failure>> list() =>
      _guard(() async => (await _ds.list()).map((e) => e.toEntity()).toList());

  @override
  Future<Result<SessionDetail, Failure>> get(String id) =>
      _guard(() async => (await _ds.get(id)).toEntity());
}
