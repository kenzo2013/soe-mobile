import 'package:dio/dio.dart';

import 'failure.dart';

/// Turns a `DioException` into a typed `Failure`.
///
/// Formats of the SOE API:
/// - v2: `{"errors": [{"code": "invalid", "message": "...", "field": "email"}]}` (translated)
/// - v1: `{"error": "..."}` (Devise) or `{"status": {"code": N, "message": "..."}}`
/// - no body or not JSON -> generic ServerFailure(code)
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
    final message = _extractMessage(data);
    final byCode = _fromV2Code(data, message);
    if (byCode != null) return byCode;
    switch (code) {
      case 400:
        return ServerFailure(400, message);
      case 401:
        return _from401(message);
      case 403:
        return const ForbiddenFailure();
      case 404:
        return const NotFoundFailure();
      case 409:
        return ConflictFailure(message);
      case 412:
        // Nouveau code (API mai 2026) : compte non confirme.
        // Avant, l'API renvoyait un 401 + message "confirm email".
        return const EmailNotConfirmedFailure();
      case 422:
        return ValidationFailure(_extractErrors(data), message);
      case 429:
        return RateLimitedFailure(message);
      case null:
        return const UnknownFailure();
      default:
        return ServerFailure(code, message);
    }
  }

  static Failure _from401(String? message) {
    if (message == null) return const UnauthorizedFailure();
    final m = message.toLowerCase();
    if (m.contains('confirm your email') ||
        m.contains('confirmer votre email') ||
        m.contains('confirm') && m.contains('email')) {
      return const EmailNotConfirmedFailure();
    }
    if (m.contains('invalid') &&
        (m.contains('password') || m.contains('e-mail'))) {
      return const InvalidCredentialsFailure();
    }
    return const UnauthorizedFailure();
  }

  /// First message found in: v2 `errors[].message`, v1 `error` (Devise),
  /// v1 `status.message`, `message`.
  static String? _extractMessage(Object? data) {
    if (data is! Map) return null;
    final v2Message = _v2Errors(data)
        .map((error) => error['message'])
        .whereType<String>()
        .firstOrNull;
    if (v2Message != null && v2Message.isNotEmpty) return v2Message;
    final err = data['error'];
    if (err is String && err.isNotEmpty) return err;
    final status = data['status'];
    if (status is Map) {
      final m = status['message'];
      if (m is String && m.isNotEmpty) return m;
    }
    final m = data['message'];
    if (m is String && m.isNotEmpty) return m;
    return null;
  }

  /// Per-field validation messages: v2 `errors[]` grouped by `field`, or a v1 `errors` map.
  static Map<String, List<String>> _extractErrors(Object? data) {
    if (data is! Map) return const {};
    final v2 = _v2Errors(data);
    if (v2.isNotEmpty) {
      final byField = <String, List<String>>{};
      for (final error in v2) {
        final field = error['field'];
        final message = error['message'];
        if (field is String && message is String) {
          byField.putIfAbsent(field, () => []).add(message);
        }
      }
      return byField;
    }
    final errors = data['errors'];
    if (errors is! Map) return const {};
    return errors.map(
      (k, v) => MapEntry(
        k.toString(),
        v is List ? v.map((e) => e.toString()).toList() : [v.toString()],
      ),
    );
  }

  /// v2 stable codes win over status and message wording (messages are translated).
  static Failure? _fromV2Code(Object? data, String? message) {
    if (data is! Map) return null;
    final code = _v2Errors(data)
        .map((error) => error['code'])
        .whereType<String>()
        .firstOrNull;
    return switch (code) {
      'invalid_credentials' => const InvalidCredentialsFailure(),
      'unconfirmed' => const EmailNotConfirmedFailure(),
      'unauthenticated' => const UnauthorizedFailure(),
      'rate_limited' => RateLimitedFailure(message),
      _ => null,
    };
  }

  /// v2 envelope: `errors` is a list of `{code, message, field}`.
  static List<Map<dynamic, dynamic>> _v2Errors(Map<dynamic, dynamic> data) {
    final errors = data['errors'];
    if (errors is! List) return const [];
    return errors.whereType<Map<dynamic, dynamic>>().toList();
  }
}
