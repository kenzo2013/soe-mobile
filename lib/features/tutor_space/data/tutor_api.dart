import 'package:dio/dio.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/error/failure.dart';
import '../../../core/network/api_endpoints_v2.dart';
import '../../../core/network/paginated.dart';
import 'tutor_models.dart';

/// A GPS position sent with « J'arrive » and « Je pars ».
typedef TutorPosition = ({double latitude, double longitude});

/// Calls of the API v2 tutor endpoints (lot 4). Returns models built from the envelope's `data`.
class TutorApi {
  const TutorApi(this._dio);
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

  MultipartFile _png(List<int> png) => MultipartFile.fromBytes(png,
      filename: 'signature.png', contentType: DioMediaType('image', 'png'));

  Map<String, double> _position(TutorPosition? position) => position == null
      ? const {}
      : {'latitude': position.latitude, 'longitude': position.longitude};

  Future<TutorHome> home() => _guard(() async => TutorHome.fromJson(
      _data(await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.tutorHome))));

  /// The sessions between two days (31 days at most), filtered as on the web
  /// ([filter]: upcoming, to_report, disputed, suspended).
  Future<List<TutorSession>> sessions(DateTime from, DateTime to,
          {String? filter}) =>
      _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            ApiEndpointsV2.tutorSessions,
            queryParameters: {
              'from': _day(from),
              'to': _day(to),
              'per_page': 100,
              if (filter != null) 'filter': filter,
            });
        return Paginated.fromEnvelope(r.data ?? const {}, TutorSession.fromJson)
            .items;
      });

  Future<TutorSessionDetail> session(int id) =>
      _guard(() async => TutorSessionDetail.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.tutorSession(id)))));

  /// « J'arrive »: by GPS ([position]) or with the parent's 4-digit [code].
  Future<TutorSessionDetail> checkIn(int id,
          {TutorPosition? position, String? code}) =>
      _guard(() async => TutorSessionDetail.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(ApiEndpointsV2.tutorCheckIn(id),
                  data: {
                ..._position(position),
                if (code != null) 'code': code,
              }))));

  /// « Je pars », with the position when there is one.
  Future<TutorSessionDetail> checkOut(int id, {TutorPosition? position}) =>
      _guard(() async => TutorSessionDetail.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.tutorCheckOut(id),
              data: _position(position)))));

  /// Moves a planned session to [date] at [startAt] (HH:MM), same month, same length; the
  /// optional [comment] (500 characters at most) goes to the family. A refusal is a 422 on
  /// `date` or `start_at`, or a 409, both with a message ready to display.
  Future<TutorSessionDetail> moveSession(int id,
          {required DateTime date, required String startAt, String? comment}) =>
      _guard(() async => TutorSessionDetail.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(ApiEndpointsV2.tutorSessionMove(id),
                  data: {
                'date': _day(date),
                'start_at': startAt,
                if (comment != null && comment.isNotEmpty) 'comment': comment,
              }))));

  /// The first published offers in the tutor's subjects (home, « Offres pour moi »).
  Future<List<TutorOfferPreview>> homeOffers({int limit = 2}) =>
      _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>('/tutor/offers',
            queryParameters: {'per_page': limit});
        return Paginated.fromEnvelope(
                r.data ?? const {}, TutorOfferPreview.fromJson)
            .items
            .take(limit)
            .toList();
      });

  Future<void> reportProblem(int id,
          {required String type, required String description}) =>
      _guard(() async {
        await _dio.post<Map<String, dynamic>>(ApiEndpointsV2.tutorProblem(id),
            data: {'report_type': type, 'description': description});
      });

  /// The report sent for the session, or null while none is sent (404).
  Future<TutorReport?> report(int sessionId) async {
    try {
      return await _guard(() async => TutorReport.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.tutorReport(sessionId)))));
    } on NotFoundFailure {
      return null;
    }
  }

  /// Sends the signed report; the times go only when corrected (HH:MM, with a reason).
  Future<TutorReport> sendReport(
    int sessionId, {
    required List<String> topics,
    required String homework,
    required String observations,
    required List<int> signature,
    String? startAt,
    String? endAt,
    String? correctionReason,
  }) =>
      _guard(() async {
        final form = FormData()
          ..fields.addAll(topics.map((topic) => MapEntry('topics[]', topic)))
          ..fields.add(MapEntry('homework', homework))
          ..fields.add(MapEntry('observations', observations))
          ..files.add(MapEntry('signature', _png(signature)));
        if (startAt != null && endAt != null && correctionReason != null) {
          form.fields
            ..add(MapEntry('start_at', startAt))
            ..add(MapEntry('end_at', endAt))
            ..add(MapEntry('correction_reason', correctionReason));
        }
        return TutorReport.fromJson(_data(await _dio.post<Map<String, dynamic>>(
            ApiEndpointsV2.tutorReport(sessionId),
            data: form)));
      });

  Future<TutorProposal> proposal(int id) =>
      _guard(() async => TutorProposal.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.tutorProposal(id)))));

  Future<TutorProposal> answerProposal(int id,
          {required bool accept, String? reason}) =>
      _guard(() async => TutorProposal.fromJson(_data(await _dio
              .post<Map<String, dynamic>>(
                  ApiEndpointsV2.tutorProposalAnswer(id),
                  data: {
                'decision': accept ? 'accept' : 'decline',
                if (reason != null) 'reason': reason,
              }))));

  Future<TutorPlanning> planning(int slotId) =>
      _guard(() async => TutorPlanning.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.tutorPlanning(slotId)))));

  /// One entry of `options` (« monday 16:00 ») per session of the week.
  Future<TutorPlanning> proposeTimes(int slotId, List<String> times) =>
      _guard(() async => TutorPlanning.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.tutorPlanning(slotId),
              data: {'times': times}))));

  Future<TutorEarnings> earnings() =>
      _guard(() async => TutorEarnings.fromJson(_data(
          await _dio.get<Map<String, dynamic>>(ApiEndpointsV2.tutorEarnings))));

  Future<List<TutorContract>> contracts() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(
            ApiEndpointsV2.tutorContracts,
            queryParameters: {'per_page': 100});
        return Paginated.fromEnvelope(
                r.data ?? const {}, TutorContract.fromJson)
            .items;
      });

  Future<TutorContract> contract(int id) =>
      _guard(() async => TutorContract.fromJson(_data(await _dio
          .get<Map<String, dynamic>>(ApiEndpointsV2.tutorContract(id)))));

  /// The drawn signature as a PNG, sent once the letter was read to the end.
  Future<TutorContract> signContract(int id, List<int> png) =>
      _guard(() async => TutorContract.fromJson(_data(await _dio
          .post<Map<String, dynamic>>(ApiEndpointsV2.tutorContractSign(id),
              data: FormData.fromMap(
                  {'read_confirmed': '1', 'signature': _png(png)})))));
}
