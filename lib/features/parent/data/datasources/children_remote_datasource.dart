import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/child_dto.dart';

class ChildrenRemoteDatasource {
  const ChildrenRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<ChildDto>> list() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.parentsStudents);
    final body = r.data!;
    final list = (body['data'] as List?) ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(_toFlatJson)
        .map(ChildDto.fromJson)
        .toList();
  }

  Future<ChildDto> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.parentsStudents}/$id',
    );
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return ChildDto.fromJson(_toFlatJson(data));
  }

  /// CDC §11.6 : avec photo → multipart/form-data avec `student[photo]`.
  /// Sans photo → JSON classique wrappé `{student: {...}}`.
  Future<ChildDto> create(
    Map<String, dynamic> payload, {
    File? photo,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parentsStudents,
      data: photo == null
          ? {'student': payload}
          : await _buildMultipart(payload, photo),
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ChildDto.fromJson(_toFlatJson(data));
  }

  /// L'API renvoie les students au format JSON:API :
  /// `{id, type, attributes: {first_name, ..., school_class: {id, type,
  /// attributes: {...}}, address: {id, type, attributes: {...}}}}`.
  /// On aplatit en remontant `attributes` à la racine + on simplifie les
  /// nested resources `school_class` et `address` pour matcher le DTO.
  static Map<String, dynamic> _toFlatJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final attrsRaw = json['attributes'];
    final out = <String, dynamic>{};
    if (id != null) out['id'] = id;
    if (attrsRaw is Map<String, dynamic>) {
      out.addAll(attrsRaw);
    } else {
      out.addAll(json);
    }
    // Aplatit aussi school_class et address si nested au format JSON:API.
    out['school_class'] = _flattenNested(out['school_class']);
    out['address'] = _flattenNested(out['address']);
    return out;
  }

  static Map<String, dynamic>? _flattenNested(dynamic v) {
    if (v is! Map<String, dynamic>) return null;
    final id = v['id']?.toString();
    final attrs = v['attributes'];
    final out = <String, dynamic>{};
    if (id != null) out['id'] = id;
    if (attrs is Map<String, dynamic>) {
      out.addAll(attrs);
    } else {
      out.addAll(v);
    }
    return out;
  }

  Future<ChildDto> update(
    String id,
    Map<String, dynamic> payload, {
    File? photo,
  }) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.parentsStudents}/$id',
      data: photo == null
          ? {'student': payload}
          : await _buildMultipart(payload, photo),
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ChildDto.fromJson(_toFlatJson(data));
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('${ApiEndpoints.parentsStudents}/$id');
  }

  /// Sérialise un payload Dart en `student[champ]` (Rails strong params)
  /// + ajoute le fichier photo en `student[photo]`.
  Future<FormData> _buildMultipart(
    Map<String, dynamic> payload,
    File photo,
  ) async {
    final map = <String, dynamic>{};
    _flatten(map, 'student', payload);
    map['student[photo]'] = await MultipartFile.fromFile(
      photo.path,
      filename: 'student_photo.jpg',
      contentType: MediaType('image', 'jpeg'),
    );
    return FormData.fromMap(map);
  }

  /// Aplatit récursivement un map/list en clés Rails-style :
  /// `{a: {b: 1, c: [2, 3]}}` → `a[b]=1`, `a[c][]=2`, `a[c][]=3`
  void _flatten(Map<String, dynamic> out, String prefix, dynamic value) {
    if (value is Map<String, dynamic>) {
      value.forEach((k, v) => _flatten(out, '$prefix[$k]', v));
    } else if (value is List) {
      for (final item in value) {
        _flatten(out, '$prefix[]', item);
      }
    } else if (value != null) {
      out[prefix] = value.toString();
    }
  }
}
