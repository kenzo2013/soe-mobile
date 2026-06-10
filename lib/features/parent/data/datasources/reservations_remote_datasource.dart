import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/parent_dashboard_dto.dart' show ReservationSummaryDto;
import '../dtos/reservation_dto.dart';

class ReservationsRemoteDatasource {
  const ReservationsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ReservationSummaryDto>> list() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.parentsReservations);
    final list = (r.data!['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ReservationSummaryDto.fromJson(_summaryJson(e)))
        .toList();
  }

  Future<ReservationDetailDto> get(String id) async {
    final r = await _dio
        .get<Map<String, dynamic>>('${ApiEndpoints.parentsReservations}/$id');
    return ReservationDetailDto.fromJson(_detailJson(r.data));
  }

  Future<ReservationDetailDto> create(Map<String, dynamic> payload) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parentsReservations,
      data: {'reservation': payload},
    );
    return ReservationDetailDto.fromJson(_detailJson(r.data));
  }

  // CDC §4.4 : actions devis = PATCH (pas POST)
  Future<ReservationDetailDto> accept(String id) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.parentsReservations}/$id/accept',
    );
    return ReservationDetailDto.fromJson(_detailJson(r.data));
  }

  Future<ReservationDetailDto> reject(String id) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.parentsReservations}/$id/reject',
    );
    return ReservationDetailDto.fromJson(_detailJson(r.data));
  }

  Future<ReservationDetailDto> negotiate(String id, int proposedAmount) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.parentsReservations}/$id/negotiate',
      data: {'proposed_amount': proposedAmount},
    );
    return ReservationDetailDto.fromJson(_detailJson(r.data));
  }

  // ── Normalisation JSON:API ────────────────────────────────────────
  // L'API renvoie `{ id, type, attributes:{ reference, status, total_amount,
  // tutoring_requests:[{ attributes:{ frequency, estimated_start_date,
  // preferred_tutor_gender, student:{attributes:{...}}, subjects:[...] }}] }}`.
  // Les DTOs attendent une forme plate → on aplatit ici.

  static Map<String, dynamic> _attrs(Object? node) {
    if (node is! Map) return const {};
    final a = node['attributes'];
    return a is Map
        ? {
            ...a.cast<String, dynamic>(),
            if (node['id'] != null) 'id': node['id']
          }
        : node.cast<String, dynamic>();
  }

  /// Premier `tutoring_request` (aplati) d'une réservation.
  static Map<String, dynamic> _firstRequest(Map<String, dynamic> resAttrs) {
    final reqs = (resAttrs['tutoring_requests'] as List?) ?? const [];
    return reqs.isEmpty ? const {} : _attrs(reqs.first);
  }

  static String _location(Map<String, dynamic> studentAttrs) {
    final addr = _attrs(studentAttrs['address']);
    final parts = [addr['neighborhood'], addr['city']]
        .where((e) => e != null && e.toString().isNotEmpty)
        .map((e) => e.toString());
    return parts.join(', ');
  }

  static List<String> _subjects(Map<String, dynamic> reqAttrs) {
    final raw = (reqAttrs['subjects'] as List?) ?? const [];
    return raw
        .map((s) =>
            s is Map ? (_attrs(s)['name'] ?? '').toString() : s.toString())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _summaryJson(Map<String, dynamic> raw) {
    final a = _attrs(raw);
    final req = _firstRequest(a);
    final student = _attrs(req['student']);
    return {
      'id': raw['id']?.toString() ?? a['id']?.toString() ?? '',
      'reference': a['reference'],
      'status': a['status'],
      'child_name': student['full_name'],
      'subjects': _subjects(req),
      'amount': a['total_amount'] ?? req['amount'],
    };
  }

  Map<String, dynamic> _detailJson(Map<String, dynamic>? body) {
    final raw = (body?['data'] as Map<String, dynamic>?) ?? body ?? const {};
    final a = _attrs(raw);
    final req = _firstRequest(a);
    final student = _attrs(req['student']);
    final loc = _location(student);
    return {
      'id': raw['id']?.toString() ?? a['id']?.toString() ?? '',
      'reference': a['reference'],
      'status': a['status'],
      'child_id': student['id']?.toString(),
      'child_name': student['full_name'],
      'subjects': _subjects(req),
      'frequency': (req['frequency'] as num?)?.toInt() ?? 1,
      'estimated_start_date': req['estimated_start_date'],
      'preferred_tutor_gender': req['preferred_tutor_gender'],
      'location': loc.isEmpty ? null : loc,
      'amount': a['total_amount'] ?? req['amount'],
      'program_text': a['program_text'],
      'created_at': a['created_at'],
    };
  }
}
