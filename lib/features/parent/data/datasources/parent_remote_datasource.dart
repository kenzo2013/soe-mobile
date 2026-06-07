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

    // Les students reviennent au format JSON:API
    // `{id, type, attributes: {first_name, ..., school_class: {...},
    // photo_url}}`. Le DTO les attend a plat avec `avatar_url` et `classe`.
    final rawStudents = (data['students'] as List?) ?? const [];
    final flatStudents = rawStudents
        .whereType<Map<String, dynamic>>()
        .map(_flattenStudent)
        .toList();

    final flatData = <String, dynamic>{
      ...data,
      'students': flatStudents,
    };

    return ParentDashboardDto.fromJson(flatData);
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
