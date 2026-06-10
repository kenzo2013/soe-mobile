import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_contract_dto.dart';
import 'tutor_remote_base.dart';

/// `GET /common/contracts`, `PATCH /common/contracts/:id` (signature).
class TutorContractsRemoteDatasource {
  const TutorContractsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<TutorContractDto>> list() async {
    final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.contracts);
    return TutorApi.dataList(r.data).map(TutorContractDto.fromJson).toList();
  }

  /// Signature électronique : multipart `contract[signature]`.
  Future<void> sign(String id, {required File signature}) async {
    final data = await TutorApi.multipart(
      'contract',
      const {},
      singleFiles: {'contract[signature]': signature},
    );
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.contracts}/$id',
      data: data,
    );
  }
}
