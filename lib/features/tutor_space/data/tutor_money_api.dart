import 'package:dio/dio.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/paginated.dart';
import 'tutor_models.dart';
import 'tutor_money_models.dart';

/// Paths of the tutor's money and document endpoints of the API v2.
abstract final class TutorMoneyEndpoints {
  static const String statements = '/tutor/earnings/history';
  static String receipt(int id) => '/tutor/earnings/receipts/$id';
  static const String payoutMethods = '/tutor/payout_methods';
  static const String payoutMethodChanges = '/tutor/payout_method_changes';
  static String confirmChange(int id) =>
      '/tutor/payout_method_changes/$id/confirm';
  static String contract(int id) => '/tutor/contracts/$id';
  static String contractPdf(int id) => '/tutor/contracts/$id/pdf';
  static String amendments(int contractId) =>
      '/tutor/contracts/$contractId/amendments';
  static String amendment(int contractId, int id) =>
      '/tutor/contracts/$contractId/amendments/$id';
  static String amendmentSign(int contractId, int id) =>
      '/tutor/contracts/$contractId/amendments/$id/sign';
  static String amendmentPdf(int contractId, int id) =>
      '/tutor/contracts/$contractId/amendments/$id/pdf';
}

/// The details of a payout method change; only those of the [kind] are sent.
class TutorPayoutChangeRequest {
  const TutorPayoutChangeRequest({
    required this.kind,
    required this.currentPassword,
    this.methodId,
    this.replacementId,
    this.operator,
    this.phone,
    this.bank = const {},
  });

  final TutorPayoutChangeKind kind;
  final String currentPassword;
  final int? methodId;
  final int? replacementId;
  final String? operator;
  final String? phone;

  /// account_holder, bank_name, account_number, iban, bic, key.
  final Map<String, String> bank;

  Map<String, dynamic> toJson() => {
        'kind': kind.value,
        'current_password': currentPassword,
        if (methodId != null) 'payment_information_id': methodId,
        if (replacementId != null) 'replacement_id': replacementId,
        if (kind.needsMobile) ...{'operator': operator, 'phone': phone},
        if (kind.needsBank) ...bank,
      };
}

/// Calls of the tutor's earnings history, payout methods, contracts text and amendments.
class TutorMoneyApi {
  const TutorMoneyApi(this._dio);
  final Dio _dio;

  Map<String, dynamic> _data(Response<Map<String, dynamic>> r) =>
      (r.data?['data'] as Map<String, dynamic>?) ?? const {};

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }

  Future<TutorDownloadLink> _link(String path, {String? lang}) =>
      _guard(() async => TutorDownloadLink.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(path,
              queryParameters: {if (lang != null) 'lang': lang}))));

  MultipartFile _png(List<int> png) => MultipartFile.fromBytes(png,
      filename: 'signature.png', contentType: DioMediaType('image', 'png'));

  /// One page of every pay statement, latest month first.
  Future<Paginated<TutorStatement>> statements({int page = 1}) =>
      _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            TutorMoneyEndpoints.statements,
            queryParameters: {'page': page, 'per_page': 20});
        return Paginated.fromEnvelope(
            r.data ?? const {}, TutorStatement.fromJson);
      });

  Future<TutorDownloadLink> receiptLink(int statementId) =>
      _link(TutorMoneyEndpoints.receipt(statementId));

  Future<List<TutorPayoutMethod>> payoutMethods() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            TutorMoneyEndpoints.payoutMethods,
            queryParameters: {'per_page': 100});
        return Paginated.fromEnvelope(
                r.data ?? const {}, TutorPayoutMethod.fromJson)
            .items;
      });

  /// Asks for the change: the password is checked, then a 6-digit code is sent by e-mail.
  Future<TutorPayoutMethodChange> requestPayoutChange(
          TutorPayoutChangeRequest request) =>
      _guard(() async => TutorPayoutMethodChange.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(TutorMoneyEndpoints.payoutMethodChanges,
              data: request.toJson()))));

  Future<TutorPayoutMethodChange> confirmPayoutChange(int id, String code) =>
      _guard(() async => TutorPayoutMethodChange.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(TutorMoneyEndpoints.confirmChange(id),
              data: {'code': code}))));

  /// A contract and its text in [lang] (fr or en).
  Future<TutorContract> contract(int id, String lang) =>
      _guard(() async => TutorContract.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(TutorMoneyEndpoints.contract(id),
              queryParameters: {'lang': lang}))));

  Future<TutorDownloadLink> contractPdfLink(int id, String lang) =>
      _link(TutorMoneyEndpoints.contractPdf(id), lang: lang);

  Future<List<TutorAmendment>> amendments(int contractId) => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            TutorMoneyEndpoints.amendments(contractId),
            queryParameters: {'per_page': 100});
        return Paginated.fromEnvelope(
                r.data ?? const {}, TutorAmendment.fromJson)
            .items;
      });

  Future<TutorAmendment> amendment(int contractId, int id, String lang) =>
      _guard(() async => TutorAmendment.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(
              TutorMoneyEndpoints.amendment(contractId, id),
              queryParameters: {'lang': lang}))));

  /// The drawn signature as a PNG, sent once the amendment was read to the end.
  Future<TutorAmendment> signAmendment(int contractId, int id, List<int> png) =>
      _guard(() async => TutorAmendment.fromJson(_data(
          await _dio.post<Map<String, dynamic>>(
              TutorMoneyEndpoints.amendmentSign(contractId, id),
              data: FormData.fromMap(
                  {'read_confirmed': '1', 'signature': _png(png)})))));

  Future<TutorDownloadLink> amendmentPdfLink(
          int contractId, int id, String lang) =>
      _link(TutorMoneyEndpoints.amendmentPdf(contractId, id), lang: lang);
}
