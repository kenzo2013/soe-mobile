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
        .whereType<Map<String, dynamic>>()
        .map((e) => SessionSummaryDto.fromJson(_summaryJson(e)))
        .toList();
  }

  // L'API renvoie les séances en JSON:API imbriqué
  // (`attributes.{start_at, end_at, status, tutor:{...}, student:{...}}`),
  // le DTO résumé attend une forme plate.
  static Map<String, dynamic> _summaryJson(Map<String, dynamic> raw) {
    final a = _attrs(raw);
    final tutor = _attrs(a['tutor']);
    final student = _attrs(a['student']);
    final subjects = ((a['subjects'] as List?) ?? const [])
        .map((s) => s is Map ? (_attrs(s)['name'] ?? '').toString() : s.toString())
        .where((s) => s.isNotEmpty)
        .toList();
    return {
      'id': raw['id']?.toString() ?? a['id']?.toString() ?? '',
      // L'API sépare `date` (jour) et `start_at`/`end_at` (heures, année 2000).
      // On recombine pour obtenir l'horodatage réel de la séance.
      'start_at': _combine(a['date'], a['start_at']),
      'duration_minutes': _durationMinutes(a['start_at'], a['end_at']),
      'subject': subjects.isEmpty ? null : subjects.join(', '),
      'tutor_name': tutor['full_name'],
      'child_name': student['full_name'],
      'status': a['status'],
    };
  }

  /// Combine la date du jour (`2026-06-16`) avec l'heure de `start_at`
  /// (`2000-01-01T16:00:00+01:00`) → `2026-06-16T16:00:00`.
  static String _combine(Object? date, Object? startAt) {
    final d = date?.toString();
    final t = DateTime.tryParse(startAt?.toString() ?? '');
    if (d == null || d.isEmpty) return startAt?.toString() ?? '';
    if (t == null) return d;
    final local = t.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${d}T$hh:$mm:00';
  }

  static int _durationMinutes(Object? startIso, Object? endIso) {
    final s = DateTime.tryParse(startIso?.toString() ?? '');
    final e = DateTime.tryParse(endIso?.toString() ?? '');
    if (s == null || e == null) return 60;
    final m = e.difference(s).inMinutes;
    return m > 0 ? m : 60;
  }

  static Map<String, dynamic> _attrs(Object? node) {
    if (node is! Map) return const {};
    final a = node['attributes'];
    if (a is Map) return a.cast<String, dynamic>();
    return node.cast<String, dynamic>();
  }

  // CDC §4.5 : detail complet via /:id/details
  Future<SessionDetailDto> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.parentsSessions}/$id/details');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return SessionDetailDto.fromJson(data);
  }
}
