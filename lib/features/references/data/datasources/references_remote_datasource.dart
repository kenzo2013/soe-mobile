import 'package:dio/dio.dart';

import '../../domain/entities/school_class.dart';

class ReferencesRemoteDatasource {
  const ReferencesRemoteDatasource(this._dio);
  final Dio _dio;

  /// CDC §7.7 : GET /references/school_classes
  ///
  /// Parser tolérant : accepte soit le format JSON:API
  /// (`{data: [{id, type, attributes: {name, …}}]}`), soit un format plat
  /// (`{data: [{id, name, …}]}`). Si l'API regroupe par niveau
  /// (`{data: {primary: [...], general: [...]}}`), on aplatit.
  Future<List<SchoolClass>> listSchoolClasses() async {
    final r = await _dio.get<Map<String, dynamic>>('/references/school_classes');
    final body = r.data!;
    final data = body['data'];
    final maps = <Map<String, dynamic>>[];

    if (data is List) {
      maps.addAll(data.cast<Map<String, dynamic>>());
    } else if (data is Map<String, dynamic>) {
      // Format groupé par niveau : {primary: [...], general: [...]}
      for (final entry in data.entries) {
        if (entry.value is List) {
          for (final item in (entry.value as List).cast<Map<String, dynamic>>()) {
            // Si l'item n'a pas d'`education`, on hérite du groupe parent.
            if (!item.containsKey('education') &&
                !(item['attributes'] is Map &&
                    (item['attributes'] as Map).containsKey('education'))) {
              item['education'] = entry.key;
            }
            maps.add(item);
          }
        }
      }
    }

    return maps.map(_parse).toList();
  }

  /// Helper format JSON:API : si `attributes` est un map, on lit dedans.
  static SchoolClass _parse(Map<String, dynamic> j) {
    final attrsRaw = j['attributes'];
    final a = attrsRaw is Map<String, dynamic> ? attrsRaw : j;
    return SchoolClass(
      id: j['id']?.toString() ?? a['id']?.toString() ?? '',
      name: a['name']?.toString() ?? a['label']?.toString() ?? '—',
      education: a['education']?.toString() ?? a['education_level']?.toString(),
      section: a['section']?.toString(),
      position: (a['position'] as num?)?.toInt(),
    );
  }
}
