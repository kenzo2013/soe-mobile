import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/references_repository.dart';
import '../datasources/references_remote_datasource.dart';

class ReferencesRepositoryImpl implements ReferencesRepository {
  const ReferencesRepositoryImpl(this._ds);
  final ReferencesRemoteDatasource _ds;

  @override
  Future<Result<SchoolClassReferences, Failure>> listSchoolClasses({
    String? education,
    String? section,
  }) async {
    try {
      return Ok(await _ds.list(education: education, section: section));
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }

  @override
  Future<Result<List<Subject>, Failure>> listSubjects() async {
    try {
      return Ok(await _ds.subjects());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }
}
