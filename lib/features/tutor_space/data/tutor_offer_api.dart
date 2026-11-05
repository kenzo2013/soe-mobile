import 'package:dio/dio.dart';

import '../../../core/error/exception_mapper.dart';
import '../../../core/network/paginated.dart';
import 'tutor_offer_models.dart';
import 'tutor_student_models.dart';

/// Calls of the API v2 offers, applications and pupils endpoints (REP-10 to REP-14).
class TutorOfferApi {
  const TutorOfferApi(this._dio);
  final Dio _dio;

  static const String offersPath = '/tutor/offers';
  static String offerPath(int id) => '/tutor/offers/$id';
  static String applyPath(int id) => '/tutor/offers/$id/apply';
  static const String applicationsPath = '/tutor/applications';
  static const String studentsPath = '/tutor/students';
  static String studentPath(int id) => '/tutor/students/$id';

  /// The size of a page of offers.
  static const int perPage = 20;

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

  Future<Paginated<TutorOffer>> offers(TutorOfferFilters filters,
          {int page = 1}) =>
      _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(offersPath,
            queryParameters: {
              ...filters.query,
              'page': page,
              'per_page': perPage
            });
        return Paginated.fromEnvelope(r.data ?? const {}, TutorOffer.fromJson);
      });

  Future<TutorOffer> offer(int id) => _guard(() async => TutorOffer.fromJson(
      _data(await _dio.get<Map<String, dynamic>>(offerPath(id)))));

  /// One application per offer; the [message] to SOE is optional.
  Future<TutorApplication> apply(int id, {String? message}) =>
      _guard(() async => TutorApplication.fromJson(
              _data(await _dio.post<Map<String, dynamic>>(applyPath(id), data: {
            if (message != null && message.trim().isNotEmpty)
              'message': message.trim(),
          }))));

  Future<List<TutorApplication>> applications() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(applicationsPath,
            queryParameters: {'per_page': 100});
        return Paginated.fromEnvelope(
                r.data ?? const {}, TutorApplication.fromJson)
            .items;
      });

  Future<List<TutorPupil>> students() => _guard(() async {
        final r = await _dio.get<Map<String, dynamic>>(studentsPath,
            queryParameters: {'per_page': 100});
        return Paginated.fromEnvelope(r.data ?? const {}, TutorPupil.fromJson)
            .items;
      });

  Future<TutorPupilFile> student(int id) =>
      _guard(() async => TutorPupilFile.fromJson(
          _data(await _dio.get<Map<String, dynamic>>(studentPath(id)))));
}
