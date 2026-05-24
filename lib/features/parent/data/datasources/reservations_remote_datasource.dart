import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/parent_dashboard_dto.dart' show ReservationSummaryDto;
import '../dtos/reservation_dto.dart';

class ReservationsRemoteDatasource {
  const ReservationsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ReservationSummaryDto>> list() async {
    final r = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.parentsReservations);
    final list = (r.data!['data'] as List?) ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(ReservationSummaryDto.fromJson)
        .toList();
  }

  Future<ReservationDetailDto> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.parentsReservations}/$id');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ReservationDetailDto.fromJson(data);
  }

  Future<ReservationDetailDto> create(Map<String, dynamic> payload) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parentsReservations,
      data: {'reservation': payload},
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ReservationDetailDto.fromJson(data);
  }

  Future<ReservationDetailDto> accept(String id) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.parentsReservations}/$id/accept',
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ReservationDetailDto.fromJson(data);
  }

  Future<ReservationDetailDto> reject(String id) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.parentsReservations}/$id/reject',
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ReservationDetailDto.fromJson(data);
  }

  Future<ReservationDetailDto> negotiate(String id, int proposedAmount) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.parentsReservations}/$id/negotiate',
      data: {'proposed_amount': proposedAmount},
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ReservationDetailDto.fromJson(data);
  }
}
