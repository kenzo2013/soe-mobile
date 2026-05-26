import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/tutor_profile.dart';
import '../../domain/repositories/tutor_profile_repository.dart';
import '../datasources/tutor_profile_remote_datasource.dart';
import '../dtos/tutor_profile_dto.dart';

class TutorProfileRepositoryImpl implements TutorProfileRepository {
  const TutorProfileRepositoryImpl(this._ds);
  final TutorProfileRemoteDatasource _ds;

  @override
  Future<Result<TutorProfile, Failure>> getPublic({
    required String studentId,
    required String tutorId,
  }) async {
    try {
      final dto = await _ds.getPublic(studentId: studentId, tutorId: tutorId);
      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ExceptionMapper.fromDio(e));
    }
  }
}
