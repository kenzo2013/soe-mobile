import 'package:dio/dio.dart';

import '../dtos/tutor_profile_dto.dart';

class TutorProfileRemoteDatasource {
  const TutorProfileRemoteDatasource(this._dio);
  final Dio _dio;

  /// CDC §4.3 :
  /// `GET /parents/students/:student_id/tutor_information/:tutor_id`
  Future<TutorProfileDto> getPublic({
    required String studentId,
    required String tutorId,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/parents/students/$studentId/tutor_information/$tutorId',
    );
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return TutorProfileDto.fromJson(data);
  }
}
