import 'package:dio/dio.dart';

import '../dtos/tutor_profile_dto.dart';

class TutorProfileRemoteDatasource {
  const TutorProfileRemoteDatasource(this._dio);
  final Dio _dio;

  Future<TutorProfileDto> getPublic(String tutorId) async {
    final r = await _dio.get<Map<String, dynamic>>('/tutors/$tutorId');
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return TutorProfileDto.fromJson(data);
  }
}
