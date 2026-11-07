import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints_v2.dart';
import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/network/paginated.dart';
import 'parent_endpoints.dart';
import 'parent_flow_models.dart';
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

  /// The invoice's payment link, null when none was created yet (404).
  Future<PaymentLink?> paymentLink(int invoiceId) async {
    try {
      return await _guard(() async => PaymentLink.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(
              ApiEndpointsV2.parentInvoicePaymentLink(invoiceId)))));
    } on NotFoundFailure {
      return null;
    }
  }

  /// Creates the link, or returns the one still usable.
  Future<PaymentLink> createPaymentLink(int invoiceId) async =>
      _guard(() async => PaymentLink.fromJson(_data(
          await _dio.post<Map<String, dynamic>>(
              ApiEndpointsV2.parentInvoicePaymentLink(invoiceId)))));

  /// A new link: the previous one stops working.
  Future<PaymentLink> regeneratePaymentLink(int invoiceId) async =>
      _guard(() async => PaymentLink.fromJson(_data(
          await _dio.post<Map<String, dynamic>>(
              ApiEndpointsV2.parentInvoicePaymentLinkRegenerate(invoiceId)))));

  /// Deactivates the link: whoever has it can no longer pay with it.
  Future<void> revokePaymentLink(int invoiceId) async => _guard(() async {
        await _dio
            .delete<void>(ApiEndpointsV2.parentInvoicePaymentLink(invoiceId));
      });

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

  List<T> _list<T>(Response<Map<String, dynamic>> r,
          T Function(Map<String, dynamic>) fromJson) =>
      Paginated.fromEnvelope(r.data ?? const {}, fromJson).items;

  /// A PDF (contract, amendment, receipt) as bytes: the endpoints need the token.
  Future<List<int>> _bytes(String path, {Map<String, dynamic>? query}) =>
      _guard(() async {
        final r = await _dio.get<List<int>>(path,
            queryParameters: query,
            options: Options(responseType: ResponseType.bytes));
        return r.data ?? const [];
      });

  // ─── References, children (PAR-02..04) ───────────────────────────────

  Future<ParentReferences> references() =>
      _guard(() async => ParentReferences.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(ParentEndpoints.references))));

  /// Creates (id null) or updates a child; [photo] is a PNG or JPEG file path.
  Future<ParentChild> saveChild(int? id, Map<String, dynamic> child,
          {String? photo}) =>
      _guard(() async {
        final Object body;
        if (photo == null) {
          body = {'child': child};
        } else {
          final form = FormData();
          void add(String key, Object? value) {
            if (value != null) form.fields.add(MapEntry(key, '$value'));
          }

          child.forEach((key, value) {
            if (value is Map) {
              value.forEach((k, v) => add('child[$key][$k]', v));
            } else {
              add('child[$key]', value);
            }
          });
          form.files.add(MapEntry(
              'child[photo]',
              await MultipartFile.fromFile(photo,
                  filename: photo.split('/').last)));
          body = form;
        }
        final r = id == null
            ? await _dio.post<Map<String, dynamic>>(
                ApiEndpointsV2.parentChildren,
                data: body)
            : await _dio.patch<Map<String, dynamic>>(
                ApiEndpointsV2.parentChild(id),
                data: body);
        return ParentChild.fromJson(_data(r));
      });

  Future<ParentChild> archiveChild(int id) =>
      _guard(() async => ParentChild.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ParentEndpoints.childArchive(id)))));

  /// A short-lived URL of the child's photo.
  Future<String?> childPhotoUrl(int id) => _guard(() async => _data(await _dio
          .get<Map<String, dynamic>>(ParentEndpoints.childPhoto(id)))['url']
      as String?);

  /// The sessions of one child over a range (PAR-03 « Séances »).
  Future<List<ParentSession>> childSessions(
          int childId, DateTime from, DateTime to) =>
      _guard(() async => _list(
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.parentSessions,
              queryParameters: {
                'from': _day(from),
                'to': _day(to),
                'child_id': childId,
                'per_page': 100
              }),
          ParentSession.fromJson));

  // ─── Request wizard (PAR-05) ─────────────────────────────────────────

  Future<ParentRequestDraft> draft() =>
      _guard(() async => ParentRequestDraft.fromJson(
          _data(await _dio.get<Map<String, dynamic>>(ParentEndpoints.draft))));

  Future<ParentRequestDraft> draftChildren(List<int> childIds) =>
      _guard(() async => ParentRequestDraft.fromJson(_data(await _dio
          .put<Map<String, dynamic>>(ParentEndpoints.draftChildren,
              data: {'child_ids': childIds}))));

  Future<ParentRequestDraft> draftNeed(ParentNeed need) =>
      _guard(() async => ParentRequestDraft.fromJson(_data(await _dio
          .put<Map<String, dynamic>>(ParentEndpoints.draftNeed(need.childId),
              data: {'need': need.toInput()}))));

  Future<ParentRequestDraft> draftSummary() =>
      _guard(() async => ParentRequestDraft.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(ParentEndpoints.draftSummary))));

  Future<ParentRequestDetail> submitDraft() =>
      _guard(() async => ParentRequestDetail.fromJson(_data(
          await _dio.post<Map<String, dynamic>>(ParentEndpoints.draftSubmit))));

  // ─── Request detail (PAR-07), tutors (PAR-09/20) ─────────────────────

  Future<ParentRequestDetail> requestDetail(int id) =>
      _guard(() async => ParentRequestDetail.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.parentRequest(id)))));

  Future<ParentRequestDetail> cancelRequest(int id, String reason) =>
      _guard(() async => ParentRequestDetail.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ParentEndpoints.requestCancel(id),
              data: {'reason': reason}))));

  Future<ParentRequestDetail> updateNeed(int requestId, ParentNeed need) =>
      _guard(() async => ParentRequestDetail.fromJson(_data(await _dio
          .patch<Map<String, dynamic>>(
              ParentEndpoints.requestNeed(requestId, need.id ?? 0),
              data: {'need': need.toInput()}))));

  Future<List<ParentTutorProfile>> tutors(int requestId) => _guard(() async {
        final data = _data(await _dio
            .get<Map<String, dynamic>>(ParentEndpoints.tutors(requestId)));
        return (data['tutors'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(ParentTutorProfile.fromJson)
            .toList();
      });

  Future<List<ParentTutorReview>> tutorReviews(int requestId, int tutorId) =>
      _guard(() async => _list(
          await _dio.get<Map<String, dynamic>>(
              ParentEndpoints.tutorReviews(requestId, tutorId),
              queryParameters: {'per_page': 20}),
          ParentTutorReview.fromJson));

  /// reason: incompatibility, punctuality, level, behaviour or other.
  Future<ParentRequestDetail> askReplacement(int requestId,
          {required int slotId, required String reason, String? comment}) =>
      _guard(() async => ParentRequestDetail.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(
                  ParentEndpoints.replacement(requestId),
                  data: {
                'slot_id': slotId,
                'reason': reason,
                'comment': comment ?? ''
              }))));

  // ─── Sessions (PAR-13), payments (PAR-15..17) ────────────────────────

  /// report_type: repeated_lateness, no_show, incorrect_check_in,
  /// unprofessional_conduct or other; [serious] for the child's safety.
  Future<void> reportProblem(int sessionId,
          {required bool serious,
          String? reportType,
          required String description}) =>
      _guard(() async {
        await _dio.post<Map<String, dynamic>>(
            ParentEndpoints.sessionProblem(sessionId),
            data: {
              'serious': serious,
              'report_type': reportType,
              'description': description
            });
      });

  Future<List<ParentPayment>> paymentsPage(int page) =>
      _guard(() async => _list(
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.parentPayments,
              queryParameters: {'page': page, 'per_page': 50}),
          ParentPayment.fromJson));

  Future<List<int>> receiptPdf(int paymentId) =>
      _bytes(ParentEndpoints.paymentReceipt(paymentId));

  // ─── Contracts and amendments (PAR-10, COM-08) ───────────────────────

  Future<List<ParentContract>> contracts() => _guard(() async => _list(
      await _dio.get<Map<String, dynamic>>(ParentEndpoints.contracts,
          queryParameters: {'per_page': 50}),
      ParentContract.fromJson));

  Future<List<int>> contractPdf(int id, {String? lang}) =>
      _bytes(ParentEndpoints.contractPdf(id),
          query: lang == null ? null : {'lang': lang});

  Future<List<ParentAmendment>> amendments(int contractId) =>
      _guard(() async => _list(
          await _dio.get<Map<String, dynamic>>(
              ParentEndpoints.amendments(contractId),
              queryParameters: {'per_page': 50}),
          ParentAmendment.fromJson));

  Future<ParentAmendment> amendment(int contractId, int id) =>
      _guard(() async => ParentAmendment.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(
              ParentEndpoints.amendment(contractId, id)))));

  Future<ParentAmendment> signAmendment(
          int contractId, int id, List<int> png) =>
      _guard(() async => ParentAmendment.fromJson(_data(
          await _dio.post<Map<String, dynamic>>(
              ParentEndpoints.amendmentSign(contractId, id),
              data: FormData.fromMap({
                'read_confirmed': '1',
                'signature': MultipartFile.fromBytes(png,
                    filename: 'signature.png',
                    contentType: DioMediaType('image', 'png')),
              })))));

  Future<List<int>> amendmentPdf(int contractId, int id, {String? lang}) =>
      _bytes(ParentEndpoints.amendmentPdf(contractId, id),
          query: lang == null ? null : {'lang': lang});

  // ─── Reviews (PAR-18) ────────────────────────────────────────────────

  Future<List<ParentReview>> reviews() => _guard(() async => _list(
      await _dio.get<Map<String, dynamic>>(ParentEndpoints.reviews,
          queryParameters: {'per_page': 50}),
      ParentReview.fromJson));

  Future<List<ParentReviewTutor>> reviewTutors() => _guard(() async => _list(
      await _dio.get<Map<String, dynamic>>(ParentEndpoints.reviewTutors,
          queryParameters: {'per_page': 50}),
      ParentReviewTutor.fromJson));

  /// Gives (reviewId null) or edits the active review of a tutor.
  Future<ParentReview> saveReview(
          {int? reviewId,
          required int tutorId,
          required int rating,
          String? comment,
          List<int> subjectIds = const []}) =>
      _guard(() async {
        final body = {
          'tutor_id': tutorId,
          'rating': rating,
          'comment': comment ?? '',
          'subject_ids': subjectIds
        };
        final r = reviewId == null
            ? await _dio.post<Map<String, dynamic>>(ParentEndpoints.reviews,
                data: body)
            : await _dio.patch<Map<String, dynamic>>(
                ParentEndpoints.review(reviewId),
                data: body);
        return ParentReview.fromJson(_data(r));
      });

  // ─── Co-parents (PAR-19) ─────────────────────────────────────────────

  Future<List<ParentCoParent>> coParents() => _guard(() async => _list(
      await _dio.get<Map<String, dynamic>>(ParentEndpoints.coParents,
          queryParameters: {'per_page': 50}),
      ParentCoParent.fromJson));

  Future<ParentCoParent> updateCoParent(int id,
          {required bool canAnswerReports}) =>
      _guard(() async => ParentCoParent.fromJson(_data(await _dio
          .patch<Map<String, dynamic>>(ParentEndpoints.coParent(id),
              data: {'can_answer_reports': canAnswerReports}))));

  Future<void> removeCoParent(int id) => _guard(() async {
        await _dio.delete<void>(ParentEndpoints.coParent(id));
      });

  Future<List<ParentInvitation>> invitations() => _guard(() async => _list(
      await _dio.get<Map<String, dynamic>>(ParentEndpoints.invitations,
          queryParameters: {'per_page': 50}),
      ParentInvitation.fromJson));

  Future<ParentInvitation> invite(Map<String, dynamic> invitation) =>
      _guard(() async => ParentInvitation.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ParentEndpoints.invitations,
              data: {'invitation': invitation}))));

  Future<ParentInvitation> resendInvitation(int id) =>
      _guard(() async => ParentInvitation.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ParentEndpoints.invitationResend(id)))));

  Future<void> removeInvitation(int id) => _guard(() async {
        await _dio.delete<void>(ParentEndpoints.invitation(id));
      });
}
