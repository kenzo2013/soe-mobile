import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/parent_dashboard_dto.dart';

class ParentRemoteDatasource {
  const ParentRemoteDatasource(this._dio);
  final Dio _dio;

  Future<ParentDashboardDto> fetchDashboard() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.parentsDashboard);
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;

    // Les students reviennent au format JSON:API
    // `{id, type, attributes: {first_name, ..., school_class: {...},
    // photo_url}}`. Le DTO les attend a plat avec `avatar_url` et `classe`.
    final rawStudents = (data['students'] as List?) ?? const [];
    final flatStudents = rawStudents
        .whereType<Map<String, dynamic>>()
        .map(_flattenStudent)
        .toList();

    // `recent_reservations` arrivent aussi au format JSON:API imbriqué
    // (`attributes.tutoring_requests[0]...`) → on aplatit pour le DTO résumé.
    final rawRes = (data['recent_reservations'] as List?) ?? const [];
    final flatRes = rawRes
        .whereType<Map<String, dynamic>>()
        .map(_flattenReservationSummary)
        .toList();

    final flatData = <String, dynamic>{
      ...data,
      'students': flatStudents,
      'recent_reservations': flatRes,
    };

    return ParentDashboardDto.fromJson(flatData);
  }

  static Map<String, dynamic> _attrs(Object? node) {
    if (node is! Map) return const {};
    final a = node['attributes'];
    return a is Map
        ? {
            ...a.cast<String, dynamic>(),
            if (node['id'] != null) 'id': node['id'],
          }
        : node.cast<String, dynamic>();
  }

  static Map<String, dynamic> _flattenReservationSummary(
    Map<String, dynamic> json,
  ) {
    final a = _attrs(json);
    final reqs = (a['tutoring_requests'] as List?) ?? const [];
    final req = reqs.isEmpty ? const <String, dynamic>{} : _attrs(reqs.first);
    final student = _attrs(req['student']);
    final subjects = ((req['subjects'] as List?) ?? const [])
        .map((s) =>
            s is Map ? (_attrs(s)['name'] ?? '').toString() : s.toString())
        .where((s) => s.isNotEmpty)
        .toList();
    return {
      'id': json['id']?.toString() ?? a['id']?.toString() ?? '',
      'reference': a['reference'],
      'status': a['status'],
      'child_name': student['full_name'],
      'subjects': subjects,
      // Montants en chaîne décimale ("80000.0") -> num pour le DTO.
      'amount': _num(a['total_amount'] ?? req['amount']),
    };
  }

  static num? _num(Object? v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  static Map<String, dynamic> _flattenStudent(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final attrsRaw = json['attributes'];
    final out = <String, dynamic>{};
    if (id != null) out['id'] = id;
    if (attrsRaw is Map<String, dynamic>) {
      out.addAll(attrsRaw);
    } else {
      out.addAll(json);
    }

    // photo_url (backend) -> avatar_url (DTO)
    if (out['avatar_url'] == null && out['photo_url'] != null) {
      out['avatar_url'] = out['photo_url'];
    }

    // school_class.attributes.formatted_name | name -> classe
    final sc = out['school_class'];
    if (sc is Map<String, dynamic>) {
      final scAttrs = sc['attributes'];
      if (scAttrs is Map<String, dynamic>) {
        out['classe'] = scAttrs['formatted_name'] ?? scAttrs['name'];
      } else {
        out['classe'] = sc['formatted_name'] ?? sc['name'];
      }
    }

    return out;
  }
}
