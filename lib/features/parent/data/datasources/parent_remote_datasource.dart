import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/parent_dashboard_dto.dart';

class ParentRemoteDatasource {
  const ParentRemoteDatasource(this._dio);
  final Dio _dio;

  Future<ParentDashboardDto> fetchDashboard() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.parentsDashboard);
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return ParentDashboardDto.fromJson(data);
  }
}
