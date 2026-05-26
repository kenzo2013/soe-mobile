import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../dtos/payment_dto.dart';

/// Endpoints CDC §4.6 :
/// - GET    /parents/payments
/// - GET    /parents/payments/:id
/// - POST   /parents/payments/create_online
/// - GET    /parents/payments/:id/check_status   (polling 5s)
/// - GET    /parents/payments/:id/download_receipt
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

  /// Initie un paiement Mobile Money (CDC §4.6).
  /// Payload : reservation_id, channel (cm.mtn|cm.orange), phone_number,
  /// amount, payment_period (date ISO).
  Future<PaymentDto> initiate(Map<String, dynamic> payload) async {
    final r = await _dio.post<Map<String, dynamic>>(
      '${ApiEndpoints.parentsPayments}/create_online',
      data: payload,
    );
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return PaymentDto.fromJson(data);
  }

  /// Polling du statut de paiement après initiation (toutes les 5s).
  Future<PaymentDto> checkStatus(String id) async {
    final r = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.parentsPayments}/$id/check_status');
    final data = (r.data!['data'] as Map<String, dynamic>?) ?? r.data!;
    return PaymentDto.fromJson(data);
  }

  /// Télécharge le reçu PDF en bytes. À sauvegarder sur disque ou
  /// ouvrir avec un viewer.
  Future<List<int>> downloadReceipt(String id) async {
    final r = await _dio.get<List<int>>(
      '${ApiEndpoints.parentsPayments}/$id/download_receipt',
      options: Options(responseType: ResponseType.bytes),
    );
    return r.data!;
  }
}
