import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/payment_dto.dart';

class PaymentsRemoteDatasource {
  const PaymentsRemoteDatasource(this._dio);
  final Dio _dio;

  Future<List<PaymentDto>> list() async {
    final r = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.parentsPayments);
    final list = (r.data!['data'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>().map(PaymentDto.fromJson).toList();
  }

  Future<PaymentDto> get(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.parentsPayments}/$id');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return PaymentDto.fromJson(data);
  }

  Future<PaymentDto> initiate(Map<String, dynamic> payload) async {
    final r = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.parentsPayments,
      data: {'payment': payload},
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return PaymentDto.fromJson(data);
  }

  Future<PaymentReceiptDto> receipt(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.parentsPayments}/$id/receipt');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return PaymentReceiptDto.fromJson(data);
  }
}
