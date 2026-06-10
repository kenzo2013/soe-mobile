import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_course_dto.dart';
import 'tutor_remote_base.dart';

/// `GET /tutors/tutoring_courses`, `GET /tutors/students/:id?reservation_id=`,
/// `POST /tutors/tutoring_courses/manage_schedules`.
class TutorCoursesRemoteDatasource {
  const TutorCoursesRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<TutorActiveCourseDto>> list() async {
    final r = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.tutorsTutoringCourses);
    return TutorApi.dataList(r.data)
        .map(TutorActiveCourseDto.fromJson)
        .toList();
  }

  Future<TutorCourseDetailDto> studentDetail({
    required String studentId,
    String? reservationId,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/tutors/students/$studentId',
      queryParameters: {
        if (reservationId != null) 'reservation_id': reservationId,
      },
    );
    return TutorCourseDetailDto.fromJson(TutorApi.dataObject(r.data));
  }

  Future<void> manageSchedules(Map<String, dynamic> payload) async {
    await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsTutoringCourses}/manage_schedules',
      data: payload,
    );
  }
}
