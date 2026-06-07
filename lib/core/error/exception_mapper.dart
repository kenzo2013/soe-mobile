import 'package:dio/dio.dart';

import 'failure.dart';

/// Convertit une `DioException` en `Failure` typée.
///
/// Formats observés sur l'API SOE (api.jeteste.site) :
/// - `{"error": "..."}`              — Devise (login 401, register 401)
/// - `{"status": {"code": N, "message": "..."}}` — pattern Rails standard (422, 409, 200)
/// - body absent ou non-JSON → ServerFailure(code) générique
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
