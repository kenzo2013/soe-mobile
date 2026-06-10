import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_job_dto.dart';
import 'tutor_remote_base.dart';

/// `GET /tutors/jobs`, `GET /tutors/jobs/:id`, `POST /tutors/candidacies`.
class TutorJobsRemoteDatasource {
  const TutorJobsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<TutorJobDto>> list() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsJobs);
    return TutorApi.dataList(r.data).map(TutorJobDto.fromJson).toList();
  }

  Future<TutorJobDto> get(String id) async {
    final r =
        await _dio.get<Map<String, dynamic>>('${ApiEndpoints.tutorsJobs}/$id');
    return TutorJobDto.fromJson(TutorApi.dataObject(r.data));
  }

  /// CDC §5.3 : `POST /tutors/candidacies { job_id }`.
  Future<void> apply(String jobId) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.tutorsCandidacies,
      data: {'job_id': jobId},
    );
  }
}
