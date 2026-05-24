import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/parent_dashboard.dart';
import '../../domain/repositories/parent_dashboard_repository.dart';
import '../datasources/parent_remote_datasource.dart';
import '../dtos/parent_dashboard_dto.dart';

class ParentDashboardRepositoryImpl implements ParentDashboardRepository {
  const ParentDashboardRepositoryImpl(this._ds);
  final ParentRemoteDatasource _ds;

  @override
  Future<Result<ParentDashboard, Failure>> fetch() async {
    try {
      final dto = await _ds.fetchDashboard();
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }
}
