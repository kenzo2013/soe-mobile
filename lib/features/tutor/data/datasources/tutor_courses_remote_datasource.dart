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
    return TutorCourseDetailDto.fromJson(
        _detailJson(TutorApi.dataObject(r.data)));
  }

  // La réponse `/tutors/students/:id` imbrique tout : `student.{age,gender}`,
  // `tutoring_requests[0].subjects`, `schedules[]` (localized_day / time_slot).
  // On aplatit pour le DTO.
  static Map<String, dynamic> _detailJson(Map<String, dynamic> raw) {
    final student = (raw['student'] as Map?) ?? const {};
    final reqs = raw['tutoring_requests'];
    final req = (reqs is List && reqs.isNotEmpty && reqs.first is Map)
        ? reqs.first as Map
        : const {};
    final slots = ((raw['schedules'] as List?) ?? const [])
        .whereType<Map>()
        .map((s) => {
              'day': (s['localized_day'] ?? s['day'] ?? '').toString(),
              'time_range':
                  (s['time_slot'] ?? s['time_range'] ?? '').toString(),
              'subject': (s['subject'] ?? '').toString(),
            })
        .toList();
    return {
      'id': student['id']?.toString() ?? raw['id']?.toString() ?? '',
      'student': student,
      'age': student['age'] ?? 0,
      'gender': student['gender'] ?? '',
      'subjects': req['subjects'] ?? const [],
      'slots': slots,
    };
  }

  Future<void> manageSchedules(Map<String, dynamic> payload) async {
    await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsTutoringCourses}/manage_schedules',
      data: payload,
    );
  }
}
