import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_dashboard_dto.dart';
import 'tutor_remote_base.dart';

/// `GET /tutors` — tableau de bord (today_sessions + stats).
class TutorDashboardRemoteDatasource {
  const TutorDashboardRemoteDatasource(this._dio);
  final Dio _dio;

  Future<TutorDashboardDto> get() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsDashboard);
    return TutorDashboardDto.fromJson(TutorApi.dataObject(r.data));
  }
}
