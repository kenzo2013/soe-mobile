import 'package:dio/dio.dart';

import 'failure.dart';

/// Convertit une `DioException` en `Failure` typée.
///
/// Référentiel des codes : voir cahier des charges §7.4.
abstract final class ExceptionMapper {
  static Failure fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.cancel:
        return const CancelledFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure();
      case DioExceptionType.unknown:
        return const UnknownFailure();
      case DioExceptionType.badResponse:
        return _fromStatus(e.response?.statusCode, e.response?.data);
    }
  }

  static Failure _fromStatus(int? code, Object? data) {
    final msg = _extractMessage(data);
    switch (code) {
      case 400:
        return ServerFailure(400, msg);
      case 401:
        return const UnauthorizedFailure();
      case 403:
        return const ForbiddenFailure();
      case 404:
        return const NotFoundFailure();
      case 409:
        return ConflictFailure(msg);
      case 422:
        return ValidationFailure(_extractErrors(data), msg);
      case null:
        return const UnknownFailure();
      default:
        if (code >= 500) return ServerFailure(code, msg);
        return ServerFailure(code, msg);
    }
  }

  static String? _extractMessage(Object? data) {
    if (data is Map && data['status'] is Map) {
      final s = data['status'] as Map;
      final m = s['message'];
      if (m is String) return m;
    }
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return null;
  }

  static Map<String, List<String>> _extractErrors(Object? data) {
    if (data is! Map) return const {};
    final errors = data['errors'];
    if (errors is! Map) return const {};
    return errors.map(
      (k, v) => MapEntry(
        k.toString(),
        v is List ? v.map((e) => e.toString()).toList() : [v.toString()],
      ),
    );
  }
}
