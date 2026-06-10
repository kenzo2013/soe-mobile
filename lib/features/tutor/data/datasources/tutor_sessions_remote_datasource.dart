import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_session_dto.dart';
import 'tutor_remote_base.dart';

/// `GET /tutors/sessions`, `GET /tutors/sessions/:id/details`,
/// `PATCH /tutors/sessions/:id`,
/// `POST /tutors/sessions/:sid/session_reports` (multipart signature).
class TutorSessionsRemoteDatasource {
  const TutorSessionsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<TutorSessionDto>> list() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsSessions);
    return TutorApi.dataList(r.data).map(TutorSessionDto.fromJson).toList();
  }

  Future<TutorSessionDetailDto> detail(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsSessions}/$id/details',
    );
    return TutorSessionDetailDto.fromJson(TutorApi.dataObject(r.data));
  }

  Future<void> update(String id, Map<String, dynamic> payload) async {
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsSessions}/$id',
      data: {'session': payload},
    );
  }

  /// CDC §5.5 : multipart `session_report[...]` + `session_report[signature]`.
  Future<void> submitReport(
    String sessionId,
    Map<String, dynamic> payload, {
    required File signature,
  }) async {
    final data = await TutorApi.multipart(
      'session_report',
      payload,
      singleFiles: {'session_report[signature]': signature},
    );
    await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsSessions}/$sessionId/session_reports',
      data: data,
    );
  }
}
