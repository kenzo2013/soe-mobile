import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_remuneration_dto.dart';
import 'tutor_remote_base.dart';

/// `GET /tutors/remunerations`.
class TutorRemunerationsRemoteDatasource {
  const TutorRemunerationsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<TutorRemunerationDto>> list() async {
    final r =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.tutorsRemunerations);
    return TutorApi.dataList(r.data)
        .map(TutorRemunerationDto.fromJson)
        .toList();
  }
}
