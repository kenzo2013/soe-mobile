import 'package:dio/dio.dart';

import '../../domain/entities/school_class.dart';
import '../../domain/entities/subject.dart';
import '../school_meta_mapping.dart';

class ReferencesRemoteDatasource {
  const ReferencesRemoteDatasource(this._dio);
  final Dio _dio;

  /// `GET /common/subjects` — catalogue des matières (juin 2026).
  ///
  /// Réponse JSON:API :
  /// ```json
  /// { "data": [
  ///     { "id": "1", "type": "subject",
  ///       "attributes": { "name": "Mathématiques", "abbr": "MATHS" } }
  /// ] }
  /// ```
  /// Namespace `common` → accessible sans rôle tuteur.
  Future<List<Subject>> subjects() async {
    final r = await _dio.get<Map<String, dynamic>>('/common/subjects');
    final data = (r.data?['data'] as List?) ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(_parseSubject)
        .toList(growable: false);
  }

  static Subject _parseSubject(Map<String, dynamic> j) {
    final a = (j['attributes'] is Map<String, dynamic>)
        ? j['attributes'] as Map<String, dynamic>
        : j;
    return Subject(
      id: j['id']?.toString() ?? '',
      name: a['name']?.toString() ?? a['abbr']?.toString() ?? '—',
      abbr: a['abbr']?.toString(),
    );
  }

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
  Future<SchoolClassReferences> list(
      {String? education, String? section}) async {
    // L'app manipule des libellés (« Général », « Francophone ») ; l'API
    // attend les enums (`general`, `francophone`) → conversion sur le filtre.
    final eduApi = SchoolMetaMapping.educationLabelToApi(education);
    final secApi = SchoolMetaMapping.sectionLabelToApi(section);
    final r = await _dio.get<Map<String, dynamic>>(
      '/common/school_classes',
      queryParameters: {
        if (eduApi != null && eduApi.isNotEmpty) 'education': eduApi,
        if (secApi != null && secApi.isNotEmpty) 'section': secApi,
      },
    );
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? const {};

    // L'API renvoie désormais les enums dans educations/sections → on les
    // re-mappe en libellés pour les pickers (cohérent avec student.education).
    final educations = ((data['educations'] as List?) ?? const [])
        .map((e) => SchoolMetaMapping.educationApiToLabel(e.toString()) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    final sections = ((data['sections'] as List?) ?? const [])
        .map((e) => SchoolMetaMapping.sectionApiToLabel(e.toString()) ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
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
    final a = (j['attributes'] is Map<String, dynamic>)
        ? j['attributes'] as Map<String, dynamic>
        : j;
    return SchoolClass(
      id: j['id']?.toString() ?? '',
      name: a['name']?.toString() ?? a['abbr']?.toString() ?? '—',
      abbr: a['abbr']?.toString(),
    );
  }
}
