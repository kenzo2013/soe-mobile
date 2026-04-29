/// Erreurs métier typées exposées à la Presentation.
///
/// Le ViewModel pattern-matche sur ces variantes ; la View en déduit le message.
sealed class Failure {
  const Failure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

/// Spécifique : login refusé parce que l'email n'a pas encore été confirmé.
/// L'API renvoie `{"error":"You have to confirm your email address before continuing."}`.
class EmailNotConfirmedFailure extends Failure {
  const EmailNotConfirmedFailure();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure();
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure();
}

class NotFoundFailure extends Failure {
  const NotFoundFailure();
}

class ConflictFailure extends Failure {
  final String? message;
  const ConflictFailure([this.message]);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  final String? message;
  const ValidationFailure(this.errors, [this.message]);
}

class ServerFailure extends Failure {
  final int code;
  final String? message;
  const ServerFailure(this.code, [this.message]);
}

class CancelledFailure extends Failure {
  const CancelledFailure();
}

class UnknownFailure extends Failure {
  const UnknownFailure();
}
