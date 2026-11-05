import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/service_contract.dart';

/// Legacy contracts of the API v1 (JSON:API `{id, type, attributes}`), still used by the v1
/// parent and tutor screens.
class CommonRemoteDatasource {
  const CommonRemoteDatasource(this._dio);
  final Dio _dio;

  // ── Contracts ──────────────────────────────────────────────
  Future<List<ServiceContract>> getContracts() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.contracts);
    final list = (r.data?['data'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_contractFromJson)
        .toList();
  }

  /// Contract signature: multipart `contract[signature]` + `contract[signed]`.
  Future<ServiceContract> signContract(String id, File signature) async {
    final form = FormData.fromMap({
      'contract[signature]': await _multipart(signature),
      'contract[signed]': 'true',
    });
    final r = await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.contracts}/$id',
      data: form,
    );
    return _contractFromJson(
      (r.data?['data'] as Map<String, dynamic>?) ?? r.data ?? {},
    );
  }

  /// Amendment signature: `amendment[signature]` + `amendment[signed]`.
  Future<void> signAmendment(
    String contractId,
    String amendmentId,
    File signature,
  ) async {
    final form = FormData.fromMap({
      'amendment[signature]': await _multipart(signature),
      'amendment[signed]': 'true',
    });
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.contracts}/$contractId/amendments/$amendmentId',
      data: form,
    );
  }

  static ServiceContract _contractFromJson(Map<String, dynamic> node) {
    final a = _attrs(node);
    final rawAmend = (a['amendments'] as List?) ?? const [];
    return ServiceContract(
      id: (node['id'] ?? a['id'] ?? '').toString(),
      reference: (a['reference'] ?? '').toString(),
      signed: a['signed'] == true,
      contentFr: (a['content_fr'] ?? a['content'] ?? '').toString(),
      contentEn: (a['content_en'] ?? '').toString(),
      createdAt: DateTime.tryParse((a['created_at'] ?? '').toString()),
      amendments: rawAmend.whereType<Map<String, dynamic>>().map((m) {
        final ma = _attrs(m);
        return ContractAmendment(
          id: (m['id'] ?? ma['id'] ?? '').toString(),
          reference: (ma['reference'] ?? '').toString(),
          signed: ma['signed'] == true,
          contentFr: (ma['content_fr'] ?? '').toString(),
          contentEn: (ma['content_en'] ?? '').toString(),
          createdAt: DateTime.tryParse((ma['created_at'] ?? '').toString()),
        );
      }).toList(),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
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

  static Future<MultipartFile> _multipart(File f) {
    final ext = f.path.split('.').last.toLowerCase();
    final subtype = ext == 'png' ? 'png' : 'jpeg';
    return MultipartFile.fromFile(
      f.path,
      filename: f.path.split(Platform.pathSeparator).last,
      contentType: MediaType('image', subtype),
    );
  }
}
