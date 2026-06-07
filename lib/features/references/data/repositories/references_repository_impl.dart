import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/repositories/references_repository.dart';
import '../datasources/references_remote_datasource.dart';

class ReferencesRepositoryImpl implements ReferencesRepository {
  const ReferencesRepositoryImpl(this._ds);
  final ReferencesRemoteDatasource _ds;

  @override
  Future<Result<List<SchoolClass>, Failure>> listSchoolClasses() async {
    try {
      return Ok(await _ds.listSchoolClasses());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }
}
