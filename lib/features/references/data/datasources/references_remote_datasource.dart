import 'package:dio/dio.dart';

import '../../domain/entities/school_class.dart';

class ReferencesRemoteDatasource {
  const ReferencesRemoteDatasource(this._dio);
  final Dio _dio;

  /// `GET /common/school_classes` — endpoint officiel (mai 2026, Swagger).
  ///
  /// Réponse :
  /// ```json
  /// {
  ///   "status": { "code": 200, "message": "..." },
  ///   "data": {
  ///     "educations": ["Primaire", "Secondaire", ...],
  ///     "sections":   ["Francophone", "Anglophone"],
  ///     "school_classes": [
  ///       { "id": "1", "type": "school_class",
  ///         "attributes": { "name": "...", "abbr": "..." } }
  ///     ]
  ///   }
  /// }
  /// ```
  ///
  /// `education` et `section` sont des query params optionnels — l'API
  /// filtre la liste retournée côté serveur (pas de filtre client).
  Future<SchoolClassReferences> list({String? education, String? section}) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '/common/school_classes',
      queryParameters: {
        if (education != null && education.isNotEmpty) 'education': education,
        if (section != null && section.isNotEmpty) 'section': section,
      },
    );
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? const {};

    final educations =
        ((data['educations'] as List?) ?? const []).map((e) => e.toString()).toList();
    final sections =
        ((data['sections'] as List?) ?? const []).map((e) => e.toString()).toList();
    final classes = ((data['school_classes'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .map(_parseClass)
        .toList();

    return SchoolClassReferences(
      educations: educations,
      sections: sections,
      classes: classes,
    );
  }

  static SchoolClass _parseClass(Map<String, dynamic> j) {
    final a =
        (j['attributes'] is Map<String, dynamic>) ? j['attributes'] as Map<String, dynamic> : j;
    return SchoolClass(
      id: j['id']?.toString() ?? '',
      name: a['name']?.toString() ?? a['abbr']?.toString() ?? '—',
      abbr: a['abbr']?.toString(),
    );
  }
}
