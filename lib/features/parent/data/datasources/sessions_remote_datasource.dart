import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/parent_dashboard_dto.dart' show SessionSummaryDto;
import '../dtos/session_detail_dto.dart';

class SessionsRemoteDatasource {
  const SessionsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<SessionSummaryDto>> list() async {
    final r = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.parentsSessions);
    final list = (r.data!['data'] as List?) ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(SessionSummaryDto.fromJson)
        .toList();
  }

  Future<SessionDetailDto> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.parentsSessions}/$id');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return SessionDetailDto.fromJson(data);
  }
}
