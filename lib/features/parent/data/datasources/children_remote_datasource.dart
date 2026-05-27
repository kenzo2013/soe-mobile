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
        .map(ChildDto.fromJson)
        .toList();
  }

  Future<ChildDto> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.parentsStudents}/$id',
    );
    final body = r.data!;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;
    return ChildDto.fromJson(data);
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
    return ChildDto.fromJson(data);
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
    return ChildDto.fromJson(data);
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
