import 'package:dio/dio.dart';

import 'failure.dart';

/// Convertit une `DioException` en `Failure` typée.
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
        return const RateLimitedFailure();
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

  /// Cherche un message dans :
  /// - `data["error"]` (Devise)
  /// - `data["status"]["message"]` (Rails standard SOE)
  /// - `data["message"]`
  static String? _extractMessage(Object? data) {
    if (data is! Map) return null;
    final v2 = _v2Errors(data);
    if (v2.isNotEmpty) return v2.first['message'] as String?;
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

  /// L'API SOE concatène les erreurs en un seul message — pas de map détaillée.
  /// On retourne une map vide ; le ViewModel affichera `message` directement.
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

  /// v2 envelope: `errors` is a list of `{code, message, field}`.
  static List<Map<dynamic, dynamic>> _v2Errors(Map<dynamic, dynamic> data) {
    final errors = data['errors'];
    if (errors is! List) return const [];
    return errors.whereType<Map<dynamic, dynamic>>().toList();
  }
}
