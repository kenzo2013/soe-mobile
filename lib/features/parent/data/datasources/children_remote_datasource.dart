import 'package:dio/dio.dart';

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

  Future<ChildDto> create(Map<String, dynamic> payload) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parentsStudents,
      data: {'student': payload},
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ChildDto.fromJson(data);
  }

  Future<ChildDto> update(String id, Map<String, dynamic> payload) async {
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.parentsStudents}/$id',
      data: {'student': payload},
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return ChildDto.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('${ApiEndpoints.parentsStudents}/$id');
  }
}
