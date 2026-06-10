import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/tutor_payment_method_dto.dart';
import 'tutor_remote_base.dart';

/// `GET/POST /tutors/payment_informations`,
/// `PATCH /tutors/payment_informations/:id/mark_as_default`,
/// `DELETE /tutors/payment_informations/:id`.
class TutorPaymentRemoteDatasource {
  const TutorPaymentRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<TutorPaymentMethodDto>> list() async {
    final r = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.tutorsPaymentInformations);
    return TutorApi.dataList(r.data)
        .map(TutorPaymentMethodDto.fromJson)
        .toList();
  }

  /// CDC §5.7 — le payload contient déjà `type` + le sous-objet adéquat
  /// (`mobile_payment` ou `bank_information`). Pas de wrapper supplémentaire.
  Future<void> create(Map<String, dynamic> payload) async {
    await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.tutorsPaymentInformations,
      data: payload,
    );
  }

  Future<void> update(String id, Map<String, dynamic> payload) async {
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsPaymentInformations}/$id',
      data: payload,
    );
  }

  Future<void> markDefault(String id) async {
    await _dio.patch<Map<String, dynamic>>(
      '${ApiEndpoints.tutorsPaymentInformations}/$id/mark_as_default',
    );
  }

  Future<void> delete(String id) async {
    await _dio.delete<void>('${ApiEndpoints.tutorsPaymentInformations}/$id');
  }
}
