import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints_v2.dart';
import '../../../core/error/exception_mapper.dart';
import '../../../core/network/paginated.dart';
import 'parent_models.dart';

/// Calls of the API v2 parent endpoints (lot 3). Returns models built from the envelope's `data`.
class ParentApi {
  const ParentApi(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      (r.data?['data'] as Map<String, dynamic>?) ?? const {};

  /// Runs a call; a Dio error becomes a Failure the screens display (ErrorView, toasts).
  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }

  String _day(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<ParentHome> home() async => _guard(() async => ParentHome.fromJson(
      _data(await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.parentHome))));

  Future<List<ParentChild>> children() async {
    return _guard(() async {
      final r = await _dio.get<Map<String, dynamic>>(
          ApiEndpointsV2.parentChildren,
          queryParameters: {'per_page': 100});
      return Paginated.fromEnvelope(r.data ?? const {}, ParentChild.fromJson)
          .items;
    });
  }

  Future<ParentChild> child(int id) async =>
      _guard(() async => ParentChild.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentChild(id)))));

  Future<List<ParentSession>> sessions(DateTime from, DateTime to) async {
    return _guard(() async {
      final r = await _dio.get<Map<String, dynamic>>(
          ApiEndpointsV2.parentSessions,
          queryParameters: {
            'from': _day(from),
            'to': _day(to),
            'per_page': 100
          });
      return Paginated.fromEnvelope(r.data ?? const {}, ParentSession.fromJson)
          .items;
    });
  }

  Future<ParentSessionDetail> session(int id) async =>
      _guard(() async => ParentSessionDetail.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentSession(id)))));

  Future<ParentSessionDetail> cancel(int id, String reason) async =>
      _guard(() async => ParentSessionDetail.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.parentSessionCancel(id),
              data: {'reason': reason}))));

  Future<ParentReport> report(int sessionId) async =>
      _guard(() async => ParentReport.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentReport(sessionId)))));

  Future<ParentReport> answerReport(int sessionId,
          {required bool approve, String? reason}) async =>
      _guard(() async => ParentReport.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(
                  ApiEndpointsV2.parentReportAnswer(sessionId),
                  data: {
                'decision': approve ? 'approve' : 'dispute',
                'reason': reason
              }))));

  Future<List<ParentInvoice>> invoices() async {
    return _guard(() async {
      final r = await _dio.get<Map<String, dynamic>>(
          ApiEndpointsV2.parentInvoices,
          queryParameters: {'per_page': 24});
      return Paginated.fromEnvelope(r.data ?? const {}, ParentInvoice.fromJson)
          .items;
    });
  }

  Future<ParentPayment> pay(int invoiceId,
          {required String operator, required String phone}) async =>
      _guard(() async => ParentPayment.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(
              ApiEndpointsV2.parentInvoicePay(invoiceId),
              data: {'operator': operator, 'phone': phone}))));

  Future<ParentPayment> payment(int id) async =>
      _guard(() async => ParentPayment.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentPayment(id)))));

  Future<List<ParentPayment>> payments() async {
    return _guard(() async {
      final r = await _dio.get<Map<String, dynamic>>(
          ApiEndpointsV2.parentPayments,
          queryParameters: {'per_page': 24});
      return Paginated.fromEnvelope(r.data ?? const {}, ParentPayment.fromJson)
          .items;
    });
  }

  Future<List<ParentRequest>> requests() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            ApiEndpointsV2.parentRequests,
            queryParameters: {'per_page': 50});
        return Paginated.fromEnvelope(
                r.data ?? const {}, ParentRequest.fromJson)
            .items;
      });

  Future<ParentRequest> request(int id) =>
      _guard(() async => ParentRequest.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentRequest(id)))));

  Future<ParentQuote> quote(int requestId) =>
      _guard(() async => ParentQuote.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentQuote(requestId)))));

  /// decision: accept, negotiate (message, proposedAmount), decline (reason) or reactivate.
  Future<ParentQuote> answerQuote(int requestId, String decision,
          {String? message, int? proposedAmount, String? reason}) =>
      _guard(() async => ParentQuote.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(
                  ApiEndpointsV2.parentQuoteAnswer(requestId),
                  data: {
                'decision': decision,
                'message': message,
                'proposed_amount': proposedAmount,
                'reason': reason
              }))));

  Future<ParentContract> contract(int id) =>
      _guard(() async => ParentContract.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentContract(id)))));

  /// The drawn signature as a PNG, sent once the text was read to the end.
  Future<ParentContract> signContract(int id, List<int> png) =>
      _guard(() async => ParentContract.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.parentContractSign(id),
              data: FormData.fromMap({
                'read_confirmed': '1',
                'signature': MultipartFile.fromBytes(png,
                    filename: 'signature.png',
                    contentType: DioMediaType('image', 'png')),
              })))));

  Future<List<ParentPlanningSlot>> planning(int requestId) => _guard(() async {
        final data = _data(await _dio.get<Map<String, dynamic>>(
            ApiEndpointsV2.parentPlanning(requestId)));
        return (data['slots'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(ParentPlanningSlot.fromJson)
            .toList();
      });

  Future<void> answerPlanning(int requestId, int slotId,
          {required bool approve, String? comment}) =>
      _guard(() async {
        await _dio.post<Map<String, dynamic>>(
            ApiEndpointsV2.parentPlanningAnswer(requestId),
            data: {
              'slot_id': slotId,
              'decision': approve ? 'approve' : 'change',
              'comment': comment
            });
      });
}
